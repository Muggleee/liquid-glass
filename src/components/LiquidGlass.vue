<template>
  <div class="liquid-glass">
    <canvas ref="canvasRef" class="gl-canvas"></canvas>
    <ControlPanel
      v-model:radius="params.radius"
      v-model:distort="params.distort"
      v-model:dispersion="params.dispersion"
      v-model:rotSpeed="params.rotSpeed"
      v-model:shadowIntensity="params.shadowIntensity"
      v-model:shadowOffsetX="params.shadowOffsetX"
      v-model:shadowOffsetY="params.shadowOffsetY"
      v-model:shadowBlur="params.shadowBlur"
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
  resizeCanvas
} from '../utils/webgl.js'

const canvasRef = ref(null)
let gl = null
let program = null
let uniforms = {}
let vao = null
let animationId = null

// 响应式参数
const params = reactive({
  radius: 0.3,
  distort: 4.0,
  dispersion: 1.3,
  rotSpeed: 1.0,
  shadowIntensity: 0.5,
  shadowOffsetX: 0.05,
  shadowOffsetY: -0.03,
  shadowBlur: 0.03
})

// 平滑鼠标位置
const mouse = reactive({ x: 0.5, y: 0.5 })
// 真实鼠标位置
const targetMouse = reactive({ x: 0.5, y: 0.5 })
const smoothing = 0.05

// 初始化WebGL
function initWebGL() {
  const canvas = canvasRef.value
  gl = canvas.getContext('webgl2')
  
  if (!gl) {
    throw new Error('不支持 WebGL2')
  }

  // 编译着色器
  const vertexShader = compileShader(gl, vertexShaderSource, gl.VERTEX_SHADER)
  const fragmentShader = compileShader(gl, fragmentShaderSource, gl.FRAGMENT_SHADER)
  
  if (!vertexShader || !fragmentShader) {
    throw new Error('着色器编译失败')
  }

  // 创建程序
  program = createProgram(gl, vertexShader, fragmentShader)
  if (!program) {
    throw new Error('程序链接失败')
  }

  gl.useProgram(program)

 
  const uniformNames = [
    'uMVMatrix', 'uPMatrix', 'uTextureMatrix', 'uTexture', 'uMaskTexture',
    'uMousePos', 'uTMousePos', 'uResolution', 'uRadius', 'uDistort',
    'uDispersion', 'uRotSpeed', 'uShadowIntensity', 'uShadowOffsetX',
    'uShadowOffsetY', 'uShadowBlur'
  ]
  
  uniformNames.forEach(name => {
    uniforms[name] = gl.getUniformLocation(program, name)
  })

  // 设置矩阵
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

function setupTextures() {
  // 创建背景纹理
  const bgCanvas = createGradientCanvas()
  createTexture(gl, 0, bgCanvas)

  // 创建遮罩纹理
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
    createTexture(gl, 0, img)
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
}

function render() {
  if (!gl || !program) return

  // 平滑鼠标移动
  mouse.x += (targetMouse.x - mouse.x) * smoothing
  mouse.y += (targetMouse.y - mouse.y) * smoothing

  // 清除画布
  gl.clear(gl.COLOR_BUFFER_BIT)

  // 更新uniforms
  gl.uniform2fv(uniforms.uResolution, [canvasRef.value.width, canvasRef.value.height])
  gl.uniform2fv(uniforms.uMousePos, [mouse.x, mouse.y])
  gl.uniform2fv(uniforms.uTMousePos, [targetMouse.x, targetMouse.y])

  updateUniforms()

  // 绘制
  gl.bindVertexArray(vao)
  gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4)

  animationId = requestAnimationFrame(render)
}

// 监听参数变化
watch(params, updateUniforms, { deep: true })

onMounted(() => {
  try {
    initWebGL()
    window.addEventListener('resize', handleResize)
    window.addEventListener('mousemove', handleMouseMove)
    render()
  } catch (error) {
    console.error('WebGL初始化失败:', error)
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
</style>
