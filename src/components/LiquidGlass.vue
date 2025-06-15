<template>
  <div class="liquid-glass">
    <canvas ref="canvasRef" class="gl-canvas"></canvas>
    
    <a 
      href="https://github.com/Muggleee/liquid-glass-vue" 
      target="_blank" 
      rel="noopener noreferrer"
      class="github-link"
      title="View on GitHub"
    >
      <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
        <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
      </svg>
    </a>
    
    <ControlPanel
      v-model:radius="params.radius"
      v-model:distort="params.distort"
      v-model:dispersion="params.dispersion"
      v-model:rotSpeed="params.rotSpeed"
      v-model:shadowIntensity="params.shadowIntensity"
      v-model:shadowOffsetX="params.shadowOffsetX"
      v-model:shadowOffsetY="params.shadowOffsetY"
      v-model:shadowBlur="params.shadowBlur"
      v-model:highlightIntensity="params.highlightIntensity"
      v-model:highlightSize="params.highlightSize"
      v-model:highlightOffsetX="params.highlightOffsetX"
      v-model:highlightOffsetY="params.highlightOffsetY"
      @upload-background="handleBackgroundUpload"
    />
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted, watch } from 'vue'
import ControlPanel from './ControlPanel.vue'
import vertexShaderSource from '../shaders/vertex.glsl?raw'
import fragmentShaderSource from '../shaders/fragment.glsl?raw'
import {
  compileShader,
  createProgram,
  createTexture,
  createGradientCanvas,
  createMaskCanvas,
  resizeCanvas,
  loadDefaultBackgroundImage
} from '../utils/webgl.js'

const canvasRef = ref(null)
let gl = null
let program = null
let uniforms = {}
let vao = null
let animationId = null
let textureResolution = { width: 512, height: 512 } // Default texture resolution

// Reactive parameters
const params = reactive({
  radius: 0.3,
  distort: 2.3,
  dispersion: 0.7, 
  rotSpeed: 1.0,
  shadowIntensity: 0.3,
  shadowOffsetX: 0.01,
  shadowOffsetY: 0.08,
  shadowBlur: 0.4,
  highlightIntensity: 0.4,
  highlightSize: 1.25,
  highlightOffsetX: 0.01,
  highlightOffsetY: 0.03
})

// Smooth mouse position
const mouse = reactive({ x: 0.5, y: 0.5 })
// Actual mouse position
const targetMouse = reactive({ x: 0.5, y: 0.5 })
const smoothing = 0.05

// Initialize WebGL
function initWebGL() {
  const canvas = canvasRef.value
  gl = canvas.getContext('webgl2')
  
  if (!gl) {
    throw new Error('WebGL2 not supported')
  }

  // Compile shaders
  const vertexShader = compileShader(gl, vertexShaderSource, gl.VERTEX_SHADER)
  const fragmentShader = compileShader(gl, fragmentShaderSource, gl.FRAGMENT_SHADER)
  
  if (!vertexShader || !fragmentShader) {
    throw new Error('Shader compilation failed')
  }

  // Create program
  program = createProgram(gl, vertexShader, fragmentShader)
  if (!program) {
    throw new Error('Program linking failed')
  }

  gl.useProgram(program)

  const uniformNames = [
    'uMVMatrix', 'uPMatrix', 'uTextureMatrix', 'uTexture', 'uMaskTexture',
    'uMousePos', 'uTMousePos', 'uResolution', 'uTextureResolution', 'uRadius', 'uDistort',
    'uDispersion', 'uRotSpeed', 'uShadowIntensity', 'uShadowOffsetX',
    'uShadowOffsetY', 'uShadowBlur', 'uHighlightIntensity', 'uHighlightSize',
    'uHighlightOffsetX', 'uHighlightOffsetY'
  ]
  
  uniformNames.forEach(name => {
    uniforms[name] = gl.getUniformLocation(program, name)
  })

  // Setup matrices
  const identityMatrix = new Float32Array([
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1
  ])
  
  gl.uniformMatrix4fv(uniforms.uMVMatrix, false, identityMatrix)
  gl.uniformMatrix4fv(uniforms.uPMatrix, false, identityMatrix)
  gl.uniformMatrix4fv(uniforms.uTextureMatrix, false, identityMatrix)
  gl.uniform1i(uniforms.uTexture, 0)
  gl.uniform1i(uniforms.uMaskTexture, 1)

  setupGeometry()
  setupTextures()
  handleResize()
}

function setupGeometry() {
  const quad = new Float32Array([
    -1, -1, 0, 0, 0,
     1, -1, 0, 1, 0,
    -1,  1, 0, 0, 1,
     1,  1, 0, 1, 1
  ])

  vao = gl.createVertexArray()
  gl.bindVertexArray(vao)

  const vbo = gl.createBuffer()
  gl.bindBuffer(gl.ARRAY_BUFFER, vbo)
  gl.bufferData(gl.ARRAY_BUFFER, quad, gl.STATIC_DRAW)

  const posLoc = gl.getAttribLocation(program, 'aVertexPosition')
  const uvLoc = gl.getAttribLocation(program, 'aTextureCoord')

  gl.enableVertexAttribArray(posLoc)
  gl.vertexAttribPointer(posLoc, 3, gl.FLOAT, false, 5 * 4, 0)

  gl.enableVertexAttribArray(uvLoc)
  gl.vertexAttribPointer(uvLoc, 2, gl.FLOAT, false, 5 * 4, 3 * 4)
}

async function setupTextures() {
  try {
    // Create background texture with default image
    const bgImage = await loadDefaultBackgroundImage()
    createTexture(gl, 0, bgImage)
    
    // Update texture resolution
    textureResolution.width = bgImage.width || 512
    textureResolution.height = bgImage.height || 512
  } catch (error) {
    console.error('Error loading default background:', error)
    // Fallback to gradient if image loading fails
    const bgCanvas = createGradientCanvas()
    createTexture(gl, 0, bgCanvas)
  }

  // Create mask texture
  const maskCanvas = createMaskCanvas()
  createTexture(gl, 1, maskCanvas)
}

function handleResize() {
  if (!gl || !canvasRef.value) return
  resizeCanvas(canvasRef.value, gl)
}

function handleMouseMove(event) {
  targetMouse.x = event.clientX / window.innerWidth
  targetMouse.y = 1 - event.clientY / window.innerHeight
}

function handleBackgroundUpload(file) {
  if (!file) return
  
  const img = new Image()
  img.onload = () => {
    // Update texture resolution
    textureResolution.width = img.width
    textureResolution.height = img.height
    
    createTexture(gl, 0, img)
    
    // Clean up the object URL
    URL.revokeObjectURL(img.src)
  }
  img.src = URL.createObjectURL(file)
}

function updateUniforms() {
  if (!gl || !program) return

  gl.uniform1f(uniforms.uRadius, params.radius)
  gl.uniform1f(uniforms.uDistort, params.distort)
  gl.uniform1f(uniforms.uDispersion, params.dispersion)
  gl.uniform1f(uniforms.uRotSpeed, params.rotSpeed)
  gl.uniform1f(uniforms.uShadowIntensity, params.shadowIntensity)
  gl.uniform1f(uniforms.uShadowOffsetX, params.shadowOffsetX)
  gl.uniform1f(uniforms.uShadowOffsetY, params.shadowOffsetY)
  gl.uniform1f(uniforms.uShadowBlur, params.shadowBlur)
  gl.uniform1f(uniforms.uHighlightIntensity, params.highlightIntensity)
  gl.uniform1f(uniforms.uHighlightSize, params.highlightSize)
  gl.uniform1f(uniforms.uHighlightOffsetX, params.highlightOffsetX)
  gl.uniform1f(uniforms.uHighlightOffsetY, params.highlightOffsetY)
}

function render() {
  if (!gl || !program) return

  // Smooth mouse movement
  mouse.x += (targetMouse.x - mouse.x) * smoothing
  mouse.y += (targetMouse.y - mouse.y) * smoothing

  // Clear canvas
  gl.clear(gl.COLOR_BUFFER_BIT)

  gl.uniform2fv(uniforms.uResolution, [canvasRef.value.width, canvasRef.value.height])
  gl.uniform2fv(uniforms.uTextureResolution, [textureResolution.width, textureResolution.height])
  gl.uniform2fv(uniforms.uMousePos, [mouse.x, mouse.y])
  gl.uniform2fv(uniforms.uTMousePos, [targetMouse.x, targetMouse.y])

  updateUniforms()

  // Draw
  gl.bindVertexArray(vao)
  gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4)

  animationId = requestAnimationFrame(render)
}

// Watch parameter changes
watch(params, updateUniforms, { deep: true })

onMounted(() => {
  try {
    initWebGL()
    window.addEventListener('resize', handleResize)
    window.addEventListener('mousemove', handleMouseMove)
    render()
  } catch (error) {
    console.error('WebGL initialization failed:', error)
  }
})

onUnmounted(() => {
  if (animationId) {
    cancelAnimationFrame(animationId)
  }
  window.removeEventListener('resize', handleResize)
  window.removeEventListener('mousemove', handleMouseMove)
})
</script>

<style scoped>
.liquid-glass {
  position: relative;
  width: 100%;
  height: 100%;
}

.gl-canvas {
  display: block;
  cursor: none;
  width: 100%;
  height: 100%;
}

.github-link {
  position: fixed;
  top: 20px;
  right: 20px;
  z-index: 1000;
  color: rgba(255, 255, 255, 0.8);
  text-decoration: none;
  padding: 12px;
  border-radius: 50%;
  background: rgba(0, 0, 0, 0.1);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.github-link:hover {
  color: rgba(255, 255, 255, 1);
  background: rgba(0, 0, 0, 0.2);
  border-color: rgba(255, 255, 255, 0.2);
  transform: scale(1.1);
}

.github-link svg {
  width: 24px;
  height: 24px;
}
</style>