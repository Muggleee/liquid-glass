# Liquid Glass Vue

[English](#english) | [中文](#中文)

**🌐 Live Demo: [http://liquid-glass.liziyang.design](http://liquid-glass.liziyang.design)**

---

## English

A WebGL liquid glass refraction effect project based on Vue3 + Vite.

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

**🌐 在线演示: [http://liquid-glass.liziyang.design](http://liquid-glass.liziyang.design)**

一个基于 Vue3 + Vite 的 WebGL 液体玻璃折射特效项目。

### 项目特性

- 🌟 **实时折射特效** - 使用 WebGL2 和 SDF 技术实现的液体玻璃效果

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

#### 性能优化

- 着色器代码已经过优化，避免了昂贵的计算
- 使用 VAO (Vertex Array Object) 减少状态切换
- 实现了高 DPI 屏幕支持

### 许可证

MIT License

### 贡献

欢迎提交 Issue 和 Pull Request！
