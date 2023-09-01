<template>
	<div class="container">
		<div class="scene-container" ref="container"></div>
		<div class="header">
			<div class="time">2023 7-1 15:30</div>
			<div class="title">嘉兴市工业经济运行预警预测平台</div>
			<div class="back">
				<div class="back_txt">退出</div>
				<div class="outer_circle">
					<div class="inner_circle">
						<div class="inner_inner_circle"></div>
					</div>
				</div>
			</div>
		</div>
		<div class="middle_content">
			<div class="map_selector">
				<div class="map_options" @click="changeMap('growth_rate_label')">
					<img class="option_icon" src="@/assets/icons/growth_rate.png" alt="增速" />
					<span class="option_name">增速</span>
				</div>
				<div class="map_options" @click="changeMap('yield_reduction_index_label')">
					<img class="option_icon" src="@/assets/icons/yield_reduction_index.png" alt="增速" />
					<span class="option_name">减产指数</span>
				</div>
				<div class="map_options" @click="changeMap('shutdown_index_label')">
					<img class="option_icon" src="@/assets/icons/shutdown_index.png" alt="增速" />
					<span class="option_name">停产指数</span>
				</div>
				<div class="map_options" @click="changeMap('electricity_consumption_label')">
					<img class="option_icon" src="@/assets/icons/electricity_consumption.png" alt="增速" />
					<span class="option_name">用电量</span>
				</div>
			</div>
		</div>
	</div>

	<div class="growth_rate_label" v-for="item in city_data" :key="item.name">
		<div class="label_item">
			<div class="label_top">
				<img class="label_icon" src="src/assets/icons/year_growth_rate.png" alt="1" />
				<span class="label_data">
					同比增速：
					<div :class="{ label_number: -1 < 0 }">-1%</div>
				</span>
			</div>
			<div class="label_bottom">
				<img class="label_icon" src="src/assets/icons/value_added_growth_rate.png" alt="2" />
				<span class="label_data">增加值增速：+1%</span>
			</div>
		</div>
		<div class="line_point">
			<div class="line"></div>
			<div class="point"></div>
		</div>
	</div>
	<div class="yield_reduction_index_label" v-for="item in city_data" :key="item.name">
		<div class="label_item">
			<div class="index_data">10%</div>
			<img class="label_icon_index" src="@/assets/icons/green_index.png" alt="blue" />
		</div>
		<div class="label_bottom">
			<svg width="10" height="50">
				<line x1="5" y1="0" x2="5" y2="200" stroke="#26ED79" />
				<circle cx="5" cy="48" r="2" fill="#26ED79" />
			</svg>
		</div>
	</div>
	<div class="shutdown_index_label" v-for="item in city_data" :key="item.name">
		<div class="label_item">
			<div class="index_data">10%</div>
			<img class="label_icon_index" src="@/assets/icons/orange_index.png" alt="blue" />
		</div>
		<div class="label_bottom">
			<svg width="10" height="50">
				<line x1="5" y1="0" x2="5" y2="200" stroke="#FF832C" />
				<circle cx="5" cy="48" r="2" fill="#FF832C" />
			</svg>
		</div>
	</div>
	<div class="electricity_consumption_label" v-for="item in city_data" :key="item.name">
		<div class="label_item">
			<div class="index_data">112亿kw.h</div>
			<img class="label_icon_index" src="@/assets/icons/blue_index.png" alt="blue" />
		</div>
		<div class="label_bottom">
			<svg width="10" height="50">
				<line x1="5" y1="0" x2="5" y2="200" stroke="#0BE7FF" />
				<circle cx="5" cy="48" r="2" fill="#0BE7FF" />
			</svg>
		</div>
	</div>
</template>

<script setup lang='ts'>
import { ref, onMounted, onBeforeUnmount, reactive } from 'vue'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import { LineGeometry } from 'three/examples/jsm/lines/LineGeometry.js'
import { LineMaterial } from 'three/examples/jsm/lines/LineMaterial.js'
import { CSS2DRenderer, CSS2DObject } from 'three/examples/jsm/renderers/CSS2DRenderer.js'
import { Reflector } from 'three/examples/jsm/objects/Reflector.js'
import vertex from '../shader/vertex.glsl?raw'
import fragment from '../shader/fragment.glsl?raw'
import * as d3 from 'd3'

let scene: any, camera: any, renderer: any, controls: any, map: any, labelRenderer: any, light2: any
let centerAxis: any
let time = { value: 0 }
const container = ref(null)
const map_type = ref<string>('growth_rate_label')

const city_data = reactive([
	{
		name: 'jsm'
	},
	{
		name: 'jsm1'
	},
	{
		name: 'jsm2'
	},
	{
		name: 'jsm3'
	},
	{
		name: 'jsm4'
	},
	{
		name: 'jsm5'
	},
	{
		name: 'jsm1'
	}
])

onMounted(async () => {
	init()
	animate()
})

onBeforeUnmount(() => {
	// 清理资源
	controls.dispose()
	renderer.dispose()
})

function init() {
	// 创建场景
	scene = new THREE.Scene()
	//创建map
	map = new THREE.Object3D()
	// 创建摄像机
	camera = new THREE.PerspectiveCamera(65, window.innerWidth / window.innerHeight, 0.1, 1000)
	camera.position.set(0, 90, 75)
	camera.lookAt(0, 0, 0)

	// 创建渲染器
	renderer = new THREE.WebGLRenderer()
	renderer.setSize(window.innerWidth, window.innerHeight)
	container.value.appendChild(renderer.domElement)

	//创建标签渲染
	labelRenderer = new CSS2DRenderer()
	labelRenderer.setSize(window.innerWidth, window.innerHeight)
	document.body.appendChild(labelRenderer.domElement)
	labelRenderer.domElement.style.position = 'absolute'
	labelRenderer.domElement.style.top = 0
	labelRenderer.domElement.style.zIndex = '10'
	labelRenderer.domElement.style.pointerEvents = 'none'

	loadMapData()
	map.position.set(0, 40, 35)
	// 添加光源
	const ambientLight = new THREE.AmbientLight(0x404040, 1)
	scene.add(ambientLight)
	initLight()

	// 创建控制器
	controls = new OrbitControls(camera, renderer.domElement)
	controls.enableDamping = true
	// 监听窗口大小变化
	window.addEventListener('resize', onWindowResize)
}

function animate() {
	requestAnimationFrame(animate)

	time.value += 0.02
	centerAxis.rotation.y += 0.01
	controls.update()
	renderer.render(scene, camera)
	labelRenderer.render(scene, camera)
}

function onWindowResize() {
	camera.aspect = window.innerWidth / window.innerHeight
	camera.updateProjectionMatrix()
	renderer.setSize(window.innerWidth, window.innerHeight)
}
//加载地图数据
function loadMapData() {
	const loader = new THREE.FileLoader()
	loader.load('/jiaxing.json', (data: any) => {
		let jsondata = JSON.parse(data)
		initMap(jsondata)
	})
	loader.load('/line.json', (data: any) => {
		let jsondata = JSON.parse(data)
		initLine(jsondata)
	})
	map.rotation.x -= Math.PI / 2
}
//初始化地图
function initMap(mapData: any) {
	//map = new THREE.Object3D()
	const projection = d3.geoMercator().center([120.8, 30.2]).scale(3250).translate([0, 0])
	mapData.features.forEach((elem: any) => {
		// 定一个省份3D对象
		const city = new THREE.Object3D()
		// 每个的 坐标 数组
		const coordinates = elem.geometry.coordinates
		// 循环坐标数组
		coordinates.forEach((multiPolygon: any) => {
			multiPolygon.forEach((polygon: any) => {
				const shape = new THREE.Shape()
				const lineMaterial = new LineMaterial({
					color: '#1C94AD',
					linewidth: 1
				})
				lineMaterial.resolution.set(window.innerWidth, window.innerHeight)
				const lineGeometry = new LineGeometry()
				let arr1 = []
				let str = ''
				for (let i = 0; i < polygon.length; i++) {
					const result = projection(polygon[i])
					if (result !== null) {
						const [x, y] = result
						if (i === 0) {
							shape.moveTo(x, -y)
						}
						shape.lineTo(x, -y)
						arr1.push(x)
						arr1.push(-y)
						arr1.push(3.01)
						str = str + x + ',' + -y + ';'
					}
				}
				lineGeometry.setPositions(arr1)

				//获取中点&设置市级文字
				const arr = str.split(';')
				const tmp_center = getPointsCenter(arr)
				console.log(tmp_center[0], elem.properties.name)
				if (tmp_center[0] < 17) {
					if (elem.properties.name === '海盐县') {
						getText(elem.properties.name, tmp_center)
						getLabel(elem.properties.name, tmp_center)
					} else if (elem.properties.name === '秀洲区') {
						tmp_center[0] -= 2
						tmp_center[1] += 5
						getText(elem.properties.name, tmp_center)
						getLabel(elem.properties.name, tmp_center)
					} else if (elem.properties.name === '嘉善县') {
						tmp_center[0] -= 0
						tmp_center[1] += 2
						getText(elem.properties.name, tmp_center)
						getLabel(elem.properties.name, tmp_center)
					} else if (elem.properties.name === '桐乡市') {
						tmp_center[0] -= 2
						tmp_center[1] += 5
						getText(elem.properties.name, tmp_center)
						getLabel(elem.properties.name, tmp_center)
					} else if (elem.properties.name === '南湖区') {
						tmp_center[0] -= 1
						tmp_center[1] += 3
						getText(elem.properties.name, tmp_center)
						getLabel(elem.properties.name, tmp_center)
					} else if (elem.properties.name === '海宁市') {
						tmp_center[0] += 3
						tmp_center[1] += 3
						getText(elem.properties.name, tmp_center)
						getLabel(elem.properties.name, tmp_center)
					} else if (elem.properties.name === '平湖市') {
						tmp_center[0] += 0
						tmp_center[1] += 4
						getText(elem.properties.name, tmp_center)
						getLabel(elem.properties.name, tmp_center)
					} else {
						getText(elem.properties.name, tmp_center)
						getLabel(elem.properties.name, tmp_center)
					}
				} else {
					console.log(0)
				}

				const extrudeSettings = {
					depth: 3,
					bevelEnabled: false
				}
				const geometry = new THREE.ExtrudeGeometry(shape, extrudeSettings)
				geometry.computeBoundingBox()
				if (geometry.boundingBox) {
					const { min, max } = geometry.boundingBox
					const material = new THREE.RawShaderMaterial({
						uniforms: {
							// 模型渐变色
							// 模型底部颜色
							u_city_color: { value: new THREE.Color('#005496') },
							// 模型顶部颜色
							u_head_color: { value: new THREE.Color('#033F87') },
							// 高度差
							u_size: { value: max.x - min.x }
						},
						vertexShader: `
                  attribute vec3 position;
                  uniform mat4 modelMatrix;
                  uniform mat4 viewMatrix;
                  uniform mat4 projectionMatrix;

                  varying vec3 v_position;

                  void main() {
                      v_position = position;
                      // 投影矩阵*视图矩阵*模型矩阵*顶点坐标
                      gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4(position, 1.0);
                  }
                  `,
						fragmentShader: `
                  precision mediump float;

                  varying vec3 v_position;

                  uniform vec3 u_city_color;
                  uniform vec3 u_head_color;
                  uniform float u_size;

                  void main(){
                      vec3 base_color = u_city_color;
                      base_color =  mix(u_head_color ,base_color,v_position.x / u_size + 0.1);

                      // 设置模型的颜色
                      gl_FragColor = vec4(base_color, 1.0);
                  }
                  `,
						transparent: false
					})

					// 地图侧部的颜色 -----------------------------------------------------------
					const material1 = new THREE.RawShaderMaterial({
						uniforms: {
							// 模型渐变色
							// 模型底部颜色
							u_city_color: { value: new THREE.Color('#005175') },
							// 模型顶部颜色
							u_head_color: { value: new THREE.Color('#00BEFA') },
							// 高度差
							u_size: { value: max.z - min.z }
						},
						vertexShader: `
                  attribute vec3 position;
                  uniform mat4 modelMatrix;
                  uniform mat4 viewMatrix;
                  uniform mat4 projectionMatrix;

                  varying vec3 v_position;

                  void main() {
                      v_position = position;
                      // 投影矩阵*视图矩阵*模型矩阵*顶点坐标
                      gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4(position, 1.0);
                  }
                  `,
						fragmentShader: `
                  precision mediump float;

                  varying vec3 v_position;

                  uniform vec3 u_city_color;
                  uniform vec3 u_head_color;
                  uniform float u_size;

                  void main(){
                      vec3 base_color = u_city_color;
                      base_color =  mix(u_head_color ,base_color,v_position.z / u_size + 0.1);

                      // 设置模型的颜色
                      gl_FragColor = vec4(base_color, 1.0);
                  }
                  `,
						transparent: false
					})
					const mesh = new THREE.Mesh(geometry, [material, material1])
					mesh.castShadow = true
					mesh.receiveShadow = true
					const line = new THREE.Line(lineGeometry, lineMaterial)
					city.add(mesh)
					city.add(line)
				}
			})
		})
		city.position.z -= 10
		map.add(city)
		// map.rotation.y = Math.PI
	})
	scene.add(map)
	// console.log(map, scene)
	// 创建地面和倒影
	const groundGeometry = new THREE.PlaneGeometry(120, 80)

	const material1 = new THREE.ShaderMaterial({
		vertexShader: vertex,
		fragmentShader: fragment,
		uniforms: {
			u_time: time,
			u_resolution: {
				value: new THREE.Vector3(1, 1, 1)
			}
		},
		side: THREE.DoubleSide,
		transparent: true,
		depthWrite: false
	})
	const ground = new THREE.Mesh(groundGeometry, material1)
	scene.add(ground)
	ground.rotation.x += Math.PI / 2
	ground.position.y = 29
	const reflector = new Reflector(groundGeometry, {
		clipBias: 0.003,
		textureWidth: window.innerWidth * window.devicePixelRatio * 0.5,
		textureHeight: window.innerHeight * window.devicePixelRatio * 0.5,
		color: '#0A64B5'
	})
	reflector.rotation.x -= Math.PI / 2
	reflector.position.y = 28
	scene.add(reflector)

	centerAxis = new THREE.Object3D()
	centerAxis.add(map)
	scene.add(centerAxis)
}

//初始化地图边缘
function initLine(mapData: any) {
	// map = new THREE.Object3D()
	const projection = d3.geoMercator().center([120.8, 30.2]).scale(3250).translate([0, 0])
	mapData.features.forEach((elem: any) => {
		// 定一个省份3D对象
		const city = new THREE.Object3D()
		// 每个的 坐标 数组
		const coordinates = elem.geometry.coordinates
		// 循环坐标数组
		coordinates.forEach((multiPolygon: any) => {
			multiPolygon.forEach((polygon: any) => {
				const lineMaterial = new LineMaterial({
					color: '#C1EBF0',
					linewidth: 2
				})
				lineMaterial.resolution.set(window.innerWidth, window.innerHeight)
				const lineGeometry = new LineGeometry()
				let arr1 = []
				let str = ''
				for (let i = 0; i < polygon.length; i++) {
					const result = projection(polygon[i])
					if (result !== null) {
						const [x, y] = result
						arr1.push(x)
						arr1.push(-y)
						arr1.push(3.01)
						str = str + x + ',' + -y + ';'
					}
				}
				lineGeometry.setPositions(arr1)
				const line = new THREE.Line(lineGeometry, lineMaterial)
				city.add(line)

				//边缘线发光
				const glowMaterial = new LineMaterial({
					color: '#fff', // White color for the glow
					linewidth: 2 // Adjust the line width as needed
				})
				glowMaterial.resolution.set(window.innerWidth, window.innerHeight)
				const glowLineGeometry = new LineGeometry()
				glowLineGeometry.setPositions(arr1)
				const glowLine = new THREE.LineSegments(glowLineGeometry, glowMaterial)
				city.add(glowLine)
			})
		})
		city.position.z += -10
		map.add(city)
	})
	// scene.add(map)
}
//初始化灯光
function initLight() {
	light2 = new THREE.PointLight('0xffffff', 0.4)
	light2.position.set(0, 30, 60)
	light2.castShadow = true
	// light2.rotation.y = Math.PI / 2
	scene.add(light2)

	const light3 = new THREE.PointLight('0xffffff', 0.4)
	light3.position.set(0, -30, 60)
	light3.castShadow = true
	// light3.rotation.y = Math.PI / 2
	scene.add(light3)
}
//获得中点
function getPointsCenter(points: any) {
	const point_num = points.length //坐标点个数
	let X = 0,
		Y = 0,
		Z = 0
	for (let i = 0; i < points.length; i++) {
		if (points[i] == '') {
			continue
		}
		let point = points[i].split(',')
		let lat, lng, x, y, z
		lat = (parseFloat(point[0]) * Math.PI) / 180
		lng = (parseFloat(point[1]) * Math.PI) / 180
		x = Math.cos(lat) * Math.cos(lng)
		y = Math.cos(lat) * Math.sin(lng)
		z = Math.sin(lat)
		X += x
		Y += y
		Z += z
	}
	X = X / point_num
	Y = Y / point_num
	Z = Z / point_num

	const tmp_lng = Math.atan2(Y, X)
	const tmp_lat = Math.atan2(Z, Math.sqrt(X * X + Y * Y))
	return [(tmp_lat * 180) / Math.PI, (tmp_lng * 180) / Math.PI]
}
//绘制文字
function getText(name: string, center_point: number[]) {
	console.log(window.innerWidth, window.innerHeight)
	const width = window.innerWidth / 1920
	const height = window.innerHeight / 1080
	const cityDiv = document.createElement('div')
	cityDiv.className = 'name'
	cityDiv.innerHTML += name
	cityDiv.style.color = '#fff'
	cityDiv.style.width = 80 * width + 'px'
	cityDiv.style.height = 105 * height + 'px'
	cityDiv.style.textAlign = 'center'
	cityDiv.style.lineHeight = 50 * height + 'px'
	cityDiv.style.fontSize = 20 * height + 'px'
	cityDiv.style.fontWeight = '400'
	const cityLabel = new CSS2DObject(cityDiv)
	cityLabel.position.set(center_point[0] + 1.5, center_point[1] - 3, -10) //相对于父级元素的位置
	map.add(cityLabel)
}
//切换地图
function changeMap(type_name: string) {
	const oldDiv = document.getElementsByClassName(`${map_type.value}`)
	for (let element of oldDiv) {
		element.style.opacity = '0'
	}
	map_type.value = type_name
	const cityDiv = document.getElementsByClassName(`${type_name}`)
	for (let element of cityDiv) {
		element.style.opacity = '1'
	}
}
//生成预警标签
function getLabel(name: string, center_point: number[]) {
	const cityDiv = document.createElement('div')
	cityDiv.className = 'label'
	const growth_rate_label = document.getElementsByClassName('growth_rate_label')[0]
	if (growth_rate_label) {
		cityDiv.appendChild(growth_rate_label)
	}
	setLabel(cityDiv, center_point)

	const cityDiv2 = document.createElement('div')
	cityDiv2.className = 'label'
	const yield_reduction_index_label = document.getElementsByClassName('yield_reduction_index_label')[0]
	if (yield_reduction_index_label) {
		yield_reduction_index_label.style.opacity = '0'
		cityDiv2.appendChild(yield_reduction_index_label)
	}
	setLabel(cityDiv2, center_point)

	const cityDiv3 = document.createElement('div')
	cityDiv3.className = 'label'
	const shutdown_index_label = document.getElementsByClassName('shutdown_index_label')[0]
	if (shutdown_index_label) {
		shutdown_index_label.style.opacity = '0'
		cityDiv3.appendChild(shutdown_index_label)
	}
	setLabel(cityDiv3, center_point)

	const cityDiv4 = document.createElement('div')
	cityDiv4.className = 'label'
	const electricity_consumption_label = document.getElementsByClassName('electricity_consumption_label')[0]
	if (electricity_consumption_label) {
		electricity_consumption_label.style.opacity = '0'
		cityDiv4.appendChild(electricity_consumption_label)
	}
	setLabel(cityDiv4, center_point)
}
function setLabel(div: any, center_point: number[]) {
	const cityLabel = new CSS2DObject(div)
	cityLabel.position.set(0, 0, 2)

	const sphere = new THREE.Object3D()
	sphere.position.set(center_point[0] + 1.5, center_point[1] - 3, 1) //相对于父级元素的位置
	sphere.add(cityLabel)
	map.add(sphere)
	// cityLabel.position.set(center_point[0] + 1.5, center_point[1] - 3, 30)
}
</script>

<style lang='scss' scoped>
@font-face {
	font-family: PangMenZhengDao;
	src: url('../assets/fonts/PangMenZhengDaoBiaoTiTi-1.ttf');
}
.container {
	width: vw(1920);
	height: vh(1080);
	background-color: black;
	.scene-container {
		position: absolute;
		width: 100%;
		overflow: hidden;
		margin: 0 auto;
		display: flex;
		align-items: center;
		justify-content: center;
		z-index: 0;
	}
	.header {
		position: relative;
		width: vw(1920);
		height: vh(162);
		margin: 0 auto;
		background: url('@/assets/icons/上标题.png') no-repeat center;
		background-repeat: no-repeat;
		background-size: 100% 100%;
		display: flex;
		justify-content: space-between;
		z-index: 1;
		.time {
			margin: vh(47) 0 0 vw(55);
			width: vw(124);
			min-width: vw(150);
			height: vh(20);
			font-size: font(20);
			font-family: PangMenZhengDao;
			font-weight: 400;
			color: #aecaf5;
			text-shadow: 0px vw(1) vw(3) rgba(5, 12, 25, 0.54);
		}
		.title {
			width: vw(582);
			font-size: vh(34);
			font-family: PangMenZhengDao;
			font-weight: 400;
			line-height: vh(50);
			color: #fff;
			text-align: center;
			margin: vh(20);
			background: linear-gradient(180deg, #6ca2ed 0%, #fff 100%);
			-webkit-background-clip: text;
			-webkit-text-fill-color: transparent;
		}
		.back {
			margin: vh(42) vw(45) 0 0;
			width: vw(70);
			min-width: 70px;
			height: vh(26);
			font-size: vh(18);
			font-family: PingFang SC;
			font-weight: bold;
			color: #f7f7f7;
			display: flex;
			align-items: center;
			.back_txt {
				min-width: 40px;
			}
			.outer_circle {
				margin-left: vw(5);
				width: vw(26);
				height: vw(26);
				border-radius: 50%;
				background-color: #74c0e5;
				display: flex;
				align-items: center;
				justify-content: center;
				.inner_circle {
					width: vw(10);
					height: vw(10);
					border-radius: 50%;
					background-color: black;
					display: flex;
					align-items: center;
					justify-content: center;
					.inner_inner_circle {
						width: vw(8);
						height: vw(8);
						border-radius: 50%;
						background-color: #74c0e5;
					}
				}
			}
		}
	}
	.middle_content {
		width: vw(1920);
		height: vh(561);
		display: flex;
		justify-content: space-between;
		margin-top: vh(-60);
		.map_selector {
			position: relative;
			width: vw(340);
			min-width: 300px;
			margin: vh(548) 0 0 vw(960);
			float: right;
			display: flex;
			align-items: center;
			justify-content: center;
			.map_options {
				position: relative;
				display: flex;
				align-items: center;
				justify-content: center;
				margin-left: vw(10);
				.option_icon {
					width: vw(30);
				}
				.option_name {
					color: #fff;
					font-size: vh(12);
				}
			}
		}
	}
}

.growth_rate_label {
	.label_item {
		width: vw(150);
		height: vh(60);
		background: transparent;
		border: vh(3) solid#09A5C0;
		border-radius: vw(8);
		color: #fff;
		box-shadow: 0 0 vw(15) vw(8) rgba(9, 165, 192, 0.5) inset;
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		.label_top {
			width: vw(150);
			height: vh(30);
			display: flex;
			align-items: center;
			justify-content: center;
			white-space: nowrap;
			margin-bottom: vh(-5);
			.label_icon {
				width: vw(38);
				height: vh(38);
			}
			.label_data {
				width: vw(110);
				height: vh(30);
				margin: vh(8) 0 0 vw(-8);
				font-size: vh(18);
				transform: scale(0.6666);
				transform-origin: 0 0;
				white-space: nowrap;

				display: flex;
				align-items: center;
				justify-content: left;
				.label_number {
					color: #fa4a4a;
					font-weight: bold;
				}
			}
		}
		.label_bottom {
			width: vw(150);
			height: vh(30);
			display: flex;
			align-items: center;
			justify-content: center;
			white-space: nowrap;
			.label_icon {
				width: vw(38);
				height: vh(38);
			}
			.label_data {
				width: vw(110);
				margin: vh(8) 0 0 vw(-8);
				font-size: vh(18);
				transform: scale(0.6666);
				transform-origin: 0 0;
				white-space: nowrap;
			}
		}
	}
	.line_point {
		width: vw(150);
		height: vh(60);
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		.line {
			width: vw(1);
			height: vh(60);
			background-color: #09a5c0;
		}
		.point {
			width: vw(5);
			height: vh(5);
			background-color: #09a5c0;
			border-radius: vw(12);
			box-shadow: 0 0 vw(10) vw(3) rgba(9, 165, 192, 0.8); /* 添加发光效果 */
		}
	}
}
.yield_reduction_index_label {
	.label_item {
		width: vw(100);
		height: vw(60);
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		margin-top: vh(5);
		.index_data {
			font-size: vh(14);
			font-family: PingFang SC;
			font-weight: bold;
			color: #fff;
		}
		.label_icon_index {
			width: vw(40);
			height: vw(40);
		}
	}
	.label_bottom {
		width: vw(100);
		height: vh(50);
		display: flex;
		align-items: center;
		justify-content: center;
	}
}
.shutdown_index_label {
	.label_item {
		width: vw(100);
		height: vh(60);
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		margin-top: vh(5);
		.index_data {
			font-size: vh(14);
			font-family: PingFang SC;
			font-weight: bold;
			color: #fff;
		}
		.label_icon_index {
			width: vw(40);
			height: vh(40);
		}
	}
	.label_bottom {
		width: vw(100);
		height: vh(50);
		display: flex;
		align-items: center;
		justify-content: center;
	}
}
.electricity_consumption_label {
	.label_item {
		width: vw(100);
		height: vh(60);
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		margin-top: vh(5);
		.index_data {
			font-size: vh(14);
			font-family: PingFang SC;
			font-weight: bold;
			color: #fff;
		}
		.label_icon_index {
			width: vw(40);
			height: vh(40);
		}
	}
	.label_bottom {
		width: vw(100);
		height: vh(50);
		display: flex;
		align-items: center;
		justify-content: center;
	}
}
</style>
