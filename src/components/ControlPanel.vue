<template>
  <div class="control-panel">
    <div class="control-group">
      <label>
        Circle Radius: <span class="value">{{ radius.toFixed(2) }}</span>
        <input
          type="range"
          :value="radius"
          @input="$emit('update:radius', parseFloat($event.target.value))"
          min="0.1"
          max="1.0"
          step="0.01"
        />
      </label>
    </div>

    <div class="control-group">
      <label>
        Distortion Strength: <span class="value">{{ distort.toFixed(2) }}</span>
        <input
          type="range"
          :value="distort"
          @input="$emit('update:distort', parseFloat($event.target.value))"
          min="0.1"
          max="5.0"
          step="0.1"
        />
      </label>
    </div>

    <div class="control-group">
      <label>
        Refraction Strength: <span class="value">{{ dispersion.toFixed(2) }}</span>
        <input
          type="range"
          :value="dispersion"
          @input="$emit('update:dispersion', parseFloat($event.target.value))"
          min="0.1"
          max="2.0"
          step="0.1"
        />
      </label>
    </div>

    <!-- <div class="control-group">
      <label>
        Rotation Speed: <span class="value">{{ rotSpeed.toFixed(2) }}</span>
        <input
          type="range"
          :value="rotSpeed"
          @input="$emit('update:rotSpeed', parseFloat($event.target.value))"
          min="0.0"
          max="1.0"
          step="0.01"
        />
      </label>
    </div> -->

    <div class="control-group">
      <label>
        Shadow Intensity: <span class="value">{{ shadowIntensity.toFixed(2) }}</span>
        <input
          type="range"
          :value="shadowIntensity"
          @input="$emit('update:shadowIntensity', parseFloat($event.target.value))"
          min="0.0"
          max="1.0"
          step="0.05"
        />
      </label>
    </div>

    <div class="control-group">
      <label>
        Shadow Offset X: <span class="value">{{ shadowOffsetX.toFixed(2) }}</span>
        <input
          type="range"
          :value="shadowOffsetX"
          @input="$emit('update:shadowOffsetX', parseFloat($event.target.value))"
          min="-0.2"
          max="0.2"
          step="0.01"
        />
      </label>
    </div>

    <div class="control-group">
      <label>
        Shadow Offset Y: <span class="value">{{ shadowOffsetY.toFixed(2) }}</span>
        <input
          type="range"
          :value="shadowOffsetY"
          @input="$emit('update:shadowOffsetY', parseFloat($event.target.value))"
          min="-0.2"
          max="0.2"
          step="0.01"
        />
      </label>
    </div>

    <div class="control-group">
      <label>
        Shadow Blur: <span class="value">{{ shadowBlur.toFixed(2) }}</span>
        <input
          type="range"
          :value="shadowBlur"
          @input="$emit('update:shadowBlur', parseFloat($event.target.value))"
          min="0.01"
          max="0.1"
          step="0.01"
        />
      </label>
    </div>

    <div class="control-group">
      <label>
        Upload Background:
        <input
          type="file"
          accept="image/*"
          @change="handleFileUpload"
          class="file-input"
        />
      </label>
    </div>
  </div>
</template>

<script setup>
defineProps({
  radius: { type: Number, default: 0.3 },
  distort: { type: Number, default: 3.0 },
  dispersion: { type: Number, default: 1.3 },
  rotSpeed: { type: Number, default: 1.0 },
  shadowIntensity: { type: Number, default: 0.2 },
  shadowOffsetX: { type: Number, default: 0 },
  shadowOffsetY: { type: Number, default: 0.03 },
  shadowBlur: { type: Number, default: 0.1 }
})

const emit = defineEmits([
  'update:radius',
  'update:distort',
  'update:dispersion',
  'update:rotSpeed',
  'update:shadowIntensity',
  'update:shadowOffsetX',
  'update:shadowOffsetY',
  'update:shadowBlur',
  'upload-background'
])

function handleFileUpload(event) {
  const file = event.target.files[0]
  if (file) {
    emit('upload-background', file)
  }
}
</script>

<style scoped>
.control-panel {
  position: absolute;
  top: 10px;
  left: 10px;
  background: rgba(255, 255, 255, 0.9);
  padding: 20px;
  border-radius: 12px;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
  font-size: 14px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  backdrop-filter: blur(10px);
  min-width: 250px;
  max-height: 80vh;
  overflow-y: auto;
}

.control-group {
  margin-bottom: 16px;
}

.control-group:last-child {
  margin-bottom: 0;
}

label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  color: #333;
}

.value {
  float: right;
  color: #666;
  font-weight: 400;
}

input[type="range"] {
  width: 100%;
  height: 6px;
  border-radius: 3px;
  background: #ddd;
  outline: none;
  -webkit-appearance: none;
  margin-top: 8px;
}

input[type="range"]::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 18px;
  height: 18px;
  border-radius: 50%;
  background: #007bff;
  cursor: pointer;
  box-shadow: 0 2px 6px rgba(0, 123, 255, 0.3);
}

input[type="range"]::-moz-range-thumb {
  width: 18px;
  height: 18px;
  border-radius: 50%;
  background: #007bff;
  cursor: pointer;
  border: none;
  box-shadow: 0 2px 6px rgba(0, 123, 255, 0.3);
}

.file-input {
  width: 100%;
  padding: 8px;
  border: 2px dashed #ddd;
  border-radius: 6px;
  background: #f9f9f9;
  cursor: pointer;
  transition: all 0.3s ease;
}

.file-input:hover {
  border-color: #007bff;
  background: #f0f8ff;
}

/* Responsive design */
@media (max-width: 768px) {
  .control-panel {
    position: fixed;
    top: 10px;
    left: 10px;
    right: 10px;
    max-height: 60vh;
    min-width: auto;
  }
}
</style>
