# Liquid Glass Vue

[English](#english) | [中文](#中文)

---

## English

A WebGL liquid glass refraction effect project based on Vue3 + Vite.

### Features

- 🌟 **Real-time Refraction Effects** - Liquid glass effects implemented using WebGL2 and SDF technology
- 🎮 **Interactive Controls** - Real-time adjustment of refraction parameters and visual effects
- 📱 **Responsive Design** - Support for desktop and mobile devices
- 🖼️ **Custom Backgrounds** - Support for uploading custom background images
- ⚡ **High Performance Rendering** - Smooth 60fps animations

### Tech Stack

- **Vue 3** - Modern frontend framework
- **Vite** - Fast build tool
- **WebGL2** - Hardware-accelerated graphics rendering
- **GLSL ES 3.0** - Shader language
- **SDF (Signed Distance Field)** - Geometric shape definition

### Quick Start

#### Install Dependencies

```bash
npm install
```

#### Development Mode

```bash
npm run dev
```

Visit http://localhost:3000 to see the effect

#### Build for Production

```bash
npm run build
```

#### Preview Production Build

```bash
npm run preview
```

### Project Structure

```
liquid-glass-vue/
├── src/
│   ├── components/          # Vue components
│   │   ├── LiquidGlass.vue  # Main WebGL component
│   │   └── ControlPanel.vue # Control panel component
│   ├── shaders/             # GLSL shader files
│   │   ├── vertex.glsl      # Vertex shader
│   │   └── fragment.glsl    # Fragment shader
│   ├── utils/               # Utility functions
│   │   └── webgl.js         # WebGL related utilities
│   ├── App.vue              # Root component
│   ├── main.js              # Entry file
│   └── style.css            # Global styles
├── index.html               # HTML template
├── vite.config.js           # Vite configuration
└── package.json             # Project configuration
```

### Control Parameters

- **Circle Radius** - Controls the size of the refraction area
- **Distortion Strength** - Adjusts the degree of deformation
- **Refraction Strength** - Controls the degree of light deflection
- **Rotation Speed** - Dynamic rotation effect speed
- **Shadow Strength** - Intensity of the shadow
- **Shadow Offset** - Position offset of the shadow
- **Shadow Blur** - Blur degree of shadow edges

### Core Technologies

#### SDF (Signed Distance Field)

Uses mathematical functions to define geometric shapes, more efficient than traditional polygon rendering:

```glsl
float sdCircle(vec2 uv, float r) { 
  return length(uv) - r; 
}
```

#### Light Refraction Simulation

Simulates light refraction through transparent media based on physical optics principles:

```glsl
vec2 offset = mix(vec2(0), normalize(st)/sd, length(st));
```

#### Real-time Shadow System

Implements complete shadow casting including distance attenuation and soft edges.

### Browser Compatibility

- Chrome 56+
- Firefox 51+
- Safari 15+
- Edge 79+

Requires modern browsers with WebGL2 support.

### Development Notes

#### Adding New Shader Effects

1. Create new `.glsl` files in the `src/shaders/` directory
2. Import and use them in `LiquidGlass.vue`
3. Add corresponding control parameters in `ControlPanel.vue`

#### Performance Optimization

- Shader code has been optimized to avoid expensive calculations
- Uses VAO (Vertex Array Object) to reduce state switching
- Implements high DPI screen support

### License

MIT License

### Contributing

Issues and Pull Requests are welcome!

---

## 中文

一个基于 Vue3 + Vite 的 WebGL 液体玻璃折射特效项目。

### 项目特性

- 🌟 **实时折射特效** - 使用 WebGL2 和 SDF 技术实现的液体玻璃效果
- 🎮 **交互式控制** - 实时调节折射参数和视觉效果
- 📱 **响应式设计** - 支持桌面和移动设备
- 🖼️ **自定义背景** - 支持上传自定义背景图片
- ⚡ **高性能渲染** - 60fps 流畅动画

### 技术栈

- **Vue 3** - 现代前端框架
- **Vite** - 快速构建工具
- **WebGL2** - 硬件加速图形渲染
- **GLSL ES 3.0** - 着色器语言
- **SDF (Signed Distance Field)** - 几何形状定义

### 快速开始

#### 安装依赖

```bash
npm install
```

#### 开发模式

```bash
npm run dev
```

访问 http://localhost:3000 查看效果

#### 构建生产版本

```bash
npm run build
```

#### 预览生产版本

```bash
npm run preview
```

### 项目结构

```
liquid-glass-vue/
├── src/
│   ├── components/          # Vue 组件
│   │   ├── LiquidGlass.vue  # 主要的 WebGL 组件
│   │   └── ControlPanel.vue # 控制面板组件
│   ├── shaders/             # GLSL 着色器文件
│   │   ├── vertex.glsl      # 顶点着色器
│   │   └── fragment.glsl    # 片段着色器
│   ├── utils/               # 工具函数
│   │   └── webgl.js         # WebGL 相关工具
│   ├── App.vue              # 根组件
│   ├── main.js              # 入口文件
│   └── style.css            # 全局样式
├── index.html               # HTML 模板
├── vite.config.js           # Vite 配置
└── package.json             # 项目配置
```

### 控制参数

- **圆半径** - 控制折射区域的大小
- **扭曲强度** - 调节形变程度
- **折射强度** - 控制光线偏折程度
- **旋转速度** - 动态旋转效果速度
- **投影强度** - 阴影的强度
- **投影偏移** - 阴影的位置偏移
- **投影模糊** - 阴影边缘的模糊程度

### 核心技术

#### SDF (有向距离场)

使用数学函数定义几何形状，比传统多边形渲染更高效：

```glsl
float sdCircle(vec2 uv, float r) { 
  return length(uv) - r; 
}
```

#### 光线折射模拟

基于物理光学原理模拟光线通过透明介质的折射效果：

```glsl
vec2 offset = mix(vec2(0), normalize(st)/sd, length(st));
```

#### 实时投影系统

实现了完整的阴影投射，包括距离衰减和柔和边缘。

### 浏览器兼容性

- Chrome 56+
- Firefox 51+
- Safari 15+
- Edge 79+

需要支持 WebGL2 的现代浏览器。

### 开发说明

#### 添加新的着色器效果

1. 在 `src/shaders/` 目录下创建新的 `.glsl` 文件
2. 在 `LiquidGlass.vue` 中导入并使用
3. 在 `ControlPanel.vue` 中添加相应的控制参数

#### 性能优化

- 着色器代码已经过优化，避免了昂贵的计算
- 使用 VAO (Vertex Array Object) 减少状态切换
- 实现了高 DPI 屏幕支持

### 许可证

MIT License

### 贡献

欢迎提交 Issue 和 Pull Request！
