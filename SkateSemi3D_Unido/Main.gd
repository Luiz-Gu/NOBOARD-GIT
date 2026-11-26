extends Node2D

@export_category("Colors")
@export var grama : Cores
@export var borda : Cores
@export var rua : Cores
@export var faixa : Cores
@export var borda_trashold : Cores

@export_category("Road")
# Roteiro da pista, determina as curvass e subidas em X posições
@export var caminho : Array[PathData] = []
@export_range(1,5,0.1) var velocidade : float = 1
@export var min_velocidade : float = 1
@export var max_velocidade : float = 6

@export_category("Sizes")
#dimensões da tela em que se está desenhando a estrada
@export var largura_total : int = 1152
@export var altura_total : int = 648
@export var largura_rua : int = 2000

@export_category("Montanha")
#desenho da montanha
@export var montanha : Cores
@export var dist_parede : float = 1.7              # distância lateral (1.7 = fim da grama andável)
@export var inclinacao_parede : float = 2.1         # quanto o topo se afasta pra fora
@export var altura_parede_min : float = 20000
@export var altura_parede_max : float = 35000
@export var distancia_previsao_curva : int = 120   # quantas fatias olha à frente
@export var forca_minima_curva : float = 0.01      # curvatura mínima pra contar como curva
@export var suavizacao_parede : float = 0.05       # menor = transição mais lenta
@export var afastamento_reta : float = 1.0         # quanto a parede se afasta em retas
@export var forca_reta : float = 0.5               # força da parede nas retas (0..1)
@export var suavizar_cume: int = 100

@export_category("Gerador de Pista")
@export var usar_gerador : bool = true          # true = ignora o 'caminho'
@export var seed_pista : int = 0                # 0 = pista diferente a cada execução

@export_group("Curvas")
enum TipoCurva { FRACA, MEDIA, FORTE, U }

# cada categoria: peso (frequência), força min/max, tamanho min/max, reta antes min/max
@export var heading_base : float = 130.0   # ângulo total por unidade de intensidade (~77 px no fundo da tela)
@export var tipos_curva : Dictionary = {
	TipoCurva.FRACA: {"peso": 30, "intensidade": Vector2(0.5, 0.8),  "tamanho": Vector2i(50, 90),   "reta": Vector2i(20, 60)},
	TipoCurva.MEDIA: {"peso": 30, "intensidade": Vector2(1.5, 2.3),  "tamanho": Vector2i(60, 120),  "reta": Vector2i(30, 80)},
	TipoCurva.FORTE: {"peso": 25, "intensidade": Vector2(3,5),  "tamanho": Vector2i(100, 160), "reta": Vector2i(50, 100)},
	TipoCurva.U:     {"peso": 15, "intensidade": Vector2(8,10),  "tamanho": Vector2i(250, 400), "reta": Vector2i(80, 150)},
}

@export_range(0.0, 1.0) var chance_alternar : float = 0.55   # chance de a próxima curva ir pro lado oposto
@export var limiar_curva_U : float = 400.0    # soma da curvatura para contar como curva em U
@export var janela_troca : int = 40           # fatias em que a parede encolhe até zero antes de trocar
@export var distancia_max_parede : int = 300  # fatias à frente em que a parede ainda é desenhada
@export_range(0.0, 1.0) var inicio_afinar : float = 0.6   # a partir de que fração da distância ela começa a afinar

@export_category("Guard Rail e Vale")
@export var dist_guardrail : float = 1.45
@export var dist_abismo : float = 1.7
@export var guardrail_altura_baixo : float = 300
@export var guardrail_altura_alto : float = 620
@export var guardrail_altura_poste : float = 700
@export var largura_poste : float = 0.03          # fração da largura da estrada
@export var espacamento_poste : int = 4           # um poste a cada N fatias
@export var distancia_max_guardrail : int = 400
@export var distancia_neblina : int = 500         # fatias até o vale ficar todo na cor da neblina
@export var cor_guardrail : Color = Color("c9ced4")
@export var cor_poste : Color = Color("6b7078")
@export var cor_vale_escuro : Color = Color("2f5d50")
@export var cor_vale_claro : Color = Color("3a6e5e")
@export var cor_neblina : Color = Color("9db8c9")
@export var cor_beirada : Color = Color("3b2f27")

@export_category("Barranco")
@export var dist_barranco : float = 1.7          # onde a rampa começa (1.7 = fim da grama andável)
@export var largura_barranco : float = 3.5       # quanto a rampa se estende para fora
@export var queda_vale : float = 2500          # profundidade no fim da rampa
@export var faixas_rampa : int = 4               # nº de degraus que formam a curva da encosta
@export var curva_rampa : float = 2          # 1 = reta, maior = cai mais no final
@export var distancia_max_barranco : int = 450
@export var cor_rampa_topo : Color = Color("3b2f27")
@export var cor_rampa_fundo : Color = Color("2c4236")
@export var preencher_fundo : bool = false       # true = pinta o fundo do vale depois da rampa
@export var cor_fundo_vale : Color = Color("1f3029")

@export_category("Texturas")
@export var tex_montanha : Texture2D
@export var tex_barranco : Texture2D
@export var escala_v_montanha : float = 0.08   # quantas repetições por fatia
@export var escala_v_barranco : float = 0.06
@export var repete_u_montanha : float = 1.0
@export var tamanho_tile : float = 6000.0   # unidades do mundo que cabem em UMA repetição da textura
@export var tamanho_tile_barranco : float = 5000.0   # unidades do mundo por repetição
@export_range(0.0, 1.0) var escurecer_fundo_rampa : float = 0.5

@export_category("Descida")
@export var descida_base : float = 120        # queda por fatia em TODA a pista (retas incluídas)
@export var reforco_curva : float = 1.6      # extra nas curvas, como fração da descida_base (0 = nenhum)
@export var suavizar_descida : int = 100       # raio do suavizador, em fatias

@export_category("Parallax")
@export var camadas : Array[Sprite2D] = []        # arraste as camadas aqui, da mais longe para a mais perto
@export var fatores : Array[float] = [0.2, 0.3, 0.6, 1.0, 1.4] 
@export var intensidade_parallax : float = 0.4
@export var suavizar_parallax : float = 20
@export var inverter_parallax : bool = true       # true = efeito espelho
var heading_mundo : float = 0.0    
var offset_camadas : Array[float] = []

@export_category("Arvores")
@export var arvores_ativas : bool = true              # uma árvore a cada N fatias
@export var dist_arvore_min : float = 3.5         # em larguras de estrada (1.7 = fim da grama)
@export var altura_arvore : float = 1800.0        # altura no mundo
@export var largura_arvore : float = 0.55         # fração da altura
@export var distancia_max_arvore : int = 350
@export var cor_arvore_escura : Color = Color("0b0b17")
@export var cor_arvore_clara : Color = Color("1c1c3a")
@export var cor_tronco : Color = Color("2a1d17")
@export var fileiras_arvore : int = 4              # fileiras de profundidade lateral
@export var espaco_arvore : int = 2                # troque o valor antigo (5) por 2
@export var dist_arvore_max : float = 9.0          # estende até a borda da tela
@export var massa_floresta : bool = true           # faixa escura de base atrás das árvores
@export var cor_massa : Color = Color("0b0b17")


#Variavel para testes
var vel_avanco : float = 1.0                 # multiplicador do avanço da pista
var curvas : Array[Dictionary] = []          # registro de cada curva gerada
const NOMES_TIPO := ["Fraca", "Média", "Forte", "U"]

var inicio_atual : int = 0

var queda_volta : float = 0.0

var lado_montanha : Array[int] = []
var forca_montanha : Array[float] = []

var ruido := FastNoiseLite.new()

var segmentos : float = 750 #profundidade do segmento

var cam : float #distância focal da camera
var lines : Array[LineData] = [] #lista da pista <- aqui o jeito do caminho já ta calculado. é um circuito, n uma geração aleatoria
var pos_atual : float = 0 #localização dentro da pista
var linhas_totais : int #tamanho da pista
var linha_ceu_x : float = 0.0 
var linha_ceu_y : float = 0.0 
var multiplicador_vel: float
#O quão longe a estrada vai antes de voltar pro inicio
var extensao_estrada: float = 15000 #o quanto a pista se extende antes de voltar ao inicio.

@onready var skyline : Parallax2D= $skyline
var centros_U : Array[int] = []   # fatia do meio de cada curva em U
var acumulo : float = 0.0

#correção montanha
var y_suave : Array[float] = []

func _ready():
	offset_camadas.resize(camadas.size())
	offset_camadas.fill(0.0)
	
	var padroes := {
		"grama": ["2f7d32", "3a8f3d"],
		"borda": ["ffffff", "d03030"],
		"rua": ["4a4a4a", "555555"],
		"faixa": ["ffffff", "ffffff"],
		"borda_trashold": ["c9c9a0", "b8b890"],
		"montanha": ["4a3b2f", "5c4a3b"],
	}
	for nome in padroes:
		if get(nome) == null:
			push_warning("'%s' estava vazio no Inspector, usando cor padrão" % nome)
			var c := Cores.new()
			c.dark = Color(padroes[nome][0])
			c.light = Color(padroes[nome][1])
			set(nome, c)

	ruido.seed = randi()
	
	ruido.seed = randi()
	ruido.frequency = 0.05
	var ultima_elevacao : float = 0
	for i in range(extensao_estrada):
		#Fatia da pista
		var line = LineData.new()
		line.z = i * segmentos + 0.00000001 #posição da fatia na pista (não pode ser 0, ent soma esse numero minusculo)
		
		#aqui define se é uma curva ou se é uma subida
		var data_rules = caminho.filter(func(d : PathData) : return i >= d.my_min and i <= d.my_max) 
		for j in data_rules:
			if j.type == 0:
				line.curvatura = j.value
			else:
				line.y = sin((i - j.my_min) / j.value) * (2000 * j.altura) 
				ultima_elevacao = line.y
		if len(data_rules.filter(func(d : PathData) : return d.type == 1)) == 0 and ultima_elevacao != 0:
			line.y = lerpf(ultima_elevacao, 0, 0.05)
			ultima_elevacao = line.y
		
		if len(data_rules.filter(func(d : PathData) : return d.type == 1)) == 0 and ultima_elevacao != 0:
			line.y = lerpf(ultima_elevacao, 0, 0.05)
			ultima_elevacao = line.y
		lines.append(line)                    
	linhas_totais = lines.size()
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	if usar_gerador:
			_gerar_pista()
			_aplicar_descida()
	_calcular_lados_montanha()
	
	
	linhas_totais = lines.size()
	print("pista criada, linhas_totais = ", linhas_totais)
	
	var painel = preload("res://DebugPanel.gd").new()
	add_child(painel)
	painel.iniciar(self)
	
signal curva(na_curva: bool, curva_dir: int)
func _process(_delta: float) -> void:
	#anda pra frente
	if lines.is_empty():
		return
	multiplicador_vel = lerpf(min_velocidade, max_velocidade, velocidade / 5)
	cam = 0.5 * multiplicador_vel

	acumulo += vel_avanco
	var passos := int(acumulo)
	acumulo -= passos
	pos_atual += segmentos * passos
	
	#sinal
	var c : float = lines[posmod(int(pos_atual / segmentos), linhas_totais)].curvatura
	if absf(c) > forca_minima_curva:
		curva.emit(true, int(signf(c)))
	else:
		curva.emit(false, 0)
	
	_atualizar_parallax(c, _delta)
	
	#chame o draw varias vezes
	queue_redraw()

#######################################################################################################################################################

func _draw() -> void:
	
	if lines.is_empty():
		return
	
	#volta pro inicio depois de terminar
	if pos_atual >= linhas_totais * segmentos:
		pos_atual -= linhas_totais * segmentos
	if pos_atual < 0:
		pos_atual += linhas_totais * segmentos
		
	var num_pos = 0
	var star_point : int = int(pos_atual / segmentos)
	var cam_h = (1500/velocidade) + lines[star_point].y #altura da camera
	var cutoff = altura_total #esconde fatias atras de estradas/morros
	var base_x = 0 
	var top_x = 0
	var visiveis : Array = []	
	inicio_atual = int(star_point) 
	for i in range(star_point, star_point + int(segmentos)):
		if i >= linhas_totais:
			num_pos = linhas_totais * segmentos
		else:
			num_pos = 0
		var y_off := queda_volta if i >= linhas_totais else 0.0
		var top_line = Projetor(lines[posmod(i, linhas_totais)], -base_x, cam_h, pos_atual - num_pos, y_off)
		var base_line = lines[posmod(i - 1, linhas_totais)]
		base_x += top_x #mudança na elevação
		top_x += top_line.curvatura #mudança na curva
		
		if top_line.cam_y >= cutoff:
			continue
			
		cutoff = top_line.cam_y
		
		#se o fmod (resto da divisão) for par ele usa o dark, se não usa o light
		#o i é o segmentoque ele ta desenhando
		var cor_rua = rua.dark if fmod((i / 4), 2) else rua.light
		var cor_grama = grama.dark if fmod((i / 8), 2) else grama.light
		var cor_faixa = faixa.dark if fmod((i / 6), 2) else faixa.light
		var cor_borda = borda.dark if fmod((i / 4), 2) else borda.light
		var cor_borda_trashold = borda_trashold.dark if fmod((i / 8), 2) else borda_trashold.light
		
		#Desenha a grama
		Draw_Seg(cor_grama, 0, base_line.cam_y, largura_total, 0, top_line.cam_y, largura_total)
		#Desenha as grama andaveis
		Draw_Seg(cor_borda_trashold, base_line.cam_x, base_line.cam_y, base_line.cam_w  * 1.7, top_line.cam_x, top_line.cam_y, top_line.cam_w * 1.7)
		#Desenha as bordas
		Draw_Seg(cor_borda, base_line.cam_x, base_line.cam_y, base_line.cam_w  * 1.2, top_line.cam_x, top_line.cam_y, top_line.cam_w * 1.2)
		#Dá os dados pra desenhar a estrada
		Draw_Seg(cor_rua, base_line.cam_x, base_line.cam_y, base_line.cam_w, top_line.cam_x, top_line.cam_y, top_line.cam_w)
		#Desenha as faixas
		Draw_Seg(cor_faixa, base_line.cam_x, base_line.cam_y, base_line.cam_w  * 0.02, top_line.cam_x, top_line.cam_y, top_line.cam_w * 0.02)
		
		var consecutiva : bool = visiveis.size() > 0 and int(visiveis[visiveis.size() - 1][2]) == i - 1
		visiveis.append([base_line, top_line, i, consecutiva])   # <- no final do loop

	# Segunda passada: de longe para perto
	var inicio := int(star_point)
	for k in range(visiveis.size() - 1, -1, -1):
		var s = visiveis[k]
		if not s[3]:
			continue   # fatia anterior foi ocultada pela crista: não desenha parede aqui
		
		var dist_fatias : float = s[2] - inicio
		
		# barranco
		var alc_b : float = dist_fatias / float(distancia_max_barranco)
		if alc_b < 1.0:
			Draw_Barranco(s[0], s[1], s[2], cam_h, 1.0 - smoothstep(0.6, 1.0, alc_b))
		
				# árvores
		if arvores_ativas and int(s[2]) % espaco_arvore == 0:
			var alc_a : float = dist_fatias / float(distancia_max_arvore)
			if alc_a < 1.0 and dist_fatias > 2.0:
				Draw_Arvore(s[0], s[1], s[2], cam_h, 1.0 - smoothstep(0.6, 1.0, alc_a))
		
		# montanha
		var alc : float = dist_fatias / float(distancia_max_parede)
		if alc < 1.0:
			var afina := 1.0 - smoothstep(inicio_afinar, 1.0, alc)
			var cor = montanha.dark if int(s[2] / 4) % 2 == 0 else montanha.light
			Draw_Parede(cor, s[0], s[1], s[2], cam_h, afina)

		# guard rail
		var alc_g : float = dist_fatias / float(distancia_max_guardrail)
		if alc_g < 1.0:
			Draw_Guardrail(s[0], s[1], s[2], cam_h, 1.0 - smoothstep(0.6, 1.0, alc_g))
		
		
func Projetor(line : LineData, cam_x : float, cam_y : float, cam_z : float, y_off : float = 0.0):
	line.y_proj = line.y + y_off
	line.scale = cam / (line.z - cam_z)
	line.cam_x = (1 + line.scale * (line.x - cam_x)) * largura_total / 2
	line.cam_y = (1 - line.scale * (line.y_proj - cam_y)) * altura_total / 2
	line.cam_w = (line.scale * largura_rua * (largura_total / 2.0))
	return line
	
func Draw_Seg(color: Color, x1: float, y1: float, w1: float, x2: float, y2: float, w2: float):
	#Define a localização dos pontos para desenho (arestas da forma)
	var points = [
		Vector2(int(x1 - w1), int(y1)), #A
		Vector2(int(x2 - w2), int(y2)), #C
		Vector2(int(x2 + w2), int(y2)), #D
		Vector2(int(x1 + w1), int(y1))  #B

	]
	#Desenha a pista
	draw_primitive(PackedVector2Array(points), PackedColorArray([color]), PackedVector2Array([]))
	
func altura_parede(i: int) -> float:
	var t := TAU * posmod(i, linhas_totais) / float(linhas_totais)
	var n := 0.7 * sin(t * 5.0 + 1.3) + 0.3 * sin(t * 11.0 + 4.1)   # só frequências baixas
	return lerpf(altura_parede_min, altura_parede_max, (n + 1.0) * 0.5)

func Draw_Parede(cor: Color, b: LineData, t: LineData, i: int, cam_h: float, afina: float = 1.0):
	var it := posmod(i, linhas_totais)
	var ib := posmod(i - 1, linhas_totais)
	if lado_montanha[it] != lado_montanha[ib]:
		return
	var lado : float = lado_montanha[it]
	var forca_t : float = forca_montanha[it] * afina
	var forca_b : float = forca_montanha[ib] * afina

	# NOVO: não desenha se o cume varia demais entre fatias vizinhas (evita "lanças")
	var dh := absf(altura_parede(i) * forca_t - altura_parede(i - 1) * forca_b)
	if dh > 400.0:
		return

	var d_in_b  = dist_parede + (1.0 - forca_b) * afastamento_reta
	var d_in_t  = dist_parede + (1.0 - forca_t) * afastamento_reta
	var d_out_b = d_in_b + inclinacao_parede
	var d_out_t = d_in_t + inclinacao_parede

	var b_in_x  = b.cam_x + lado * b.cam_w * d_in_b
	var b_out_x = b.cam_x + lado * b.cam_w * d_out_b
	var t_in_x  = t.cam_x + lado * t.cam_w * d_in_t
	var t_out_x = t.cam_x + lado * t.cam_w * d_out_t

	var y_cume_b : float = y_suave[ib] - lines[ib].y + b.y_proj
	var y_cume_t : float = y_suave[it] - lines[it].y + t.y_proj
	var b_topo_y = (1 - b.scale * (y_cume_b + altura_parede(i - 1) * forca_b - cam_h)) * altura_total / 2
	var t_topo_y = (1 - t.scale * (y_cume_t + altura_parede(i) * forca_t - cam_h)) * altura_total / 2

	var pontos = [
		Vector2(int(b_in_x),  int(b.cam_y)),
		Vector2(int(t_in_x),  int(t.cam_y)),
		Vector2(int(t_out_x), int(t_topo_y)),
		Vector2(int(b_out_x), int(b_topo_y)),
	]
	var h_b : float = altura_parede(i - 1) * forca_b
	var h_t : float = altura_parede(i) * forca_t
	var v_b := (float(i - 1) * segmentos) / tamanho_tile
	var v_t := (float(i) * segmentos) / tamanho_tile
	var uvs := PackedVector2Array([
		Vector2(0.0, v_b),
		Vector2(0.0, v_t),
		Vector2(h_t / tamanho_tile, v_t),
		Vector2(h_b / tamanho_tile, v_b),
	])
	var tinta := Color.WHITE.lerp(Color(0.85, 0.85, 0.9), 0.0)   # branco: textura com a cor original
	_quad_tex(PackedVector2Array(pontos), uvs, tinta, tex_montanha)
	

func _calcular_lados_montanha() -> void:
	var n := linhas_totais
	lado_montanha.resize(n)
	forca_montanha.resize(n)

	var trocas : Array[int] = []
	if usar_gerador:
		trocas = centros_U.duplicate()
	else:
		var i := 0
		while i < n:
			if absf(lines[i].curvatura) > forca_minima_curva:
				var ini := i
				var soma := 0.0
				while i < n and absf(lines[i].curvatura) > forca_minima_curva:
					soma += lines[i].curvatura
					i += 1
				if absf(soma) >= limiar_curva_U:
					trocas.append((ini + i) / 2)
			else:
				i += 1

	trocas.sort()
	if trocas.size() % 2 == 1:
		trocas.pop_back()      # número par, para a volta da pista fechar sem emenda

	var lado := -1
	var prox := 0
	for k in range(n):
		if prox < trocas.size() and k >= trocas[prox]:
			lado = -lado
			prox += 1
		var dist := n
		for c in trocas:
			dist = mini(dist, absi(k - c))
		lado_montanha[k] = lado
		forca_montanha[k] = clampf(dist / float(janela_troca), 0.0, 1.0)
	
func _gerar_pista() -> void:
	var n := linhas_totais
	var rng := RandomNumberGenerator.new()
	if seed_pista != 0:
		rng.seed = seed_pista
	else:
		rng.randomize()

	centros_U.clear()
	curvas.clear()
	for l in lines:
		l.curvatura = 0.0

	var i := 0
	var lado := 1 if rng.randf() < 0.5 else -1
	var tipo_anterior := -1

	while true:
		var tipo := _sortear_tipo(rng)
		# evita repetir a mesma categoria muitas vezes seguidas
		if tipo == tipo_anterior and rng.randf() < 0.5:
			tipo = _sortear_tipo(rng)
		var cfg : Dictionary = tipos_curva[tipo]
		var reta : Vector2i = cfg["reta"]
		var tam_r : Vector2i = cfg["tamanho"]

		i += rng.randi_range(reta.x, reta.y)
		var tam := rng.randi_range(tam_r.x, tam_r.y)
		if i + tam >= n - 30:
			break

		if rng.randf() < chance_alternar:
			lado = -lado
		var forca := _escrever_curva(i, tam, tipo, lado, rng)
		curvas.append({"ini": i, "tam": tam, "tipo": tipo, "forca": forca})
		if tipo == TipoCurva.U:
			centros_U.append(i + tam / 2)
		i += tam
		tipo_anterior = tipo

func _y_tela(l: LineData, h: float, cam_h: float) -> float:
	return (1 - l.scale * (l.y_proj + h - cam_h)) * altura_total / 2

func Draw_Guardrail(b: LineData, t: LineData, i: int, cam_h: float, afina: float = 1.0) -> void:
	var it := posmod(i, linhas_totais)
	var ib := posmod(i - 1, linhas_totais)
	if lado_montanha[it] != lado_montanha[ib]:
		return
	var lado : float = -lado_montanha[it]
	var f_b : float = forca_montanha[ib] * afina
	var f_t : float = forca_montanha[it] * afina
	if f_t < 0.02 and f_b < 0.02:
		return

	var xb := b.cam_x + lado * b.cam_w * dist_guardrail
	var xt := t.cam_x + lado * t.cam_w * dist_guardrail

	# viga (com leve variação de tom para dar ritmo)
	var cor_viga := cor_guardrail if (i / 2) % 2 == 0 else cor_guardrail.darkened(0.12)
	draw_primitive(
		PackedVector2Array([
			Vector2(xb, _y_tela(b, guardrail_altura_baixo * f_b, cam_h)),
			Vector2(xt, _y_tela(t, guardrail_altura_baixo * f_t, cam_h)),
			Vector2(xt, _y_tela(t, guardrail_altura_alto * f_t, cam_h)),
			Vector2(xb, _y_tela(b, guardrail_altura_alto * f_b, cam_h)),
		]),
		PackedColorArray([cor_viga]), PackedVector2Array([]))

	# poste
	if i % espacamento_poste == 0:
		var w := t.cam_w * largura_poste
		var y_topo := _y_tela(t, guardrail_altura_poste * f_t, cam_h)
		draw_primitive(
			PackedVector2Array([
				Vector2(xt - w, t.cam_y), Vector2(xt + w, t.cam_y),
				Vector2(xt + w, y_topo), Vector2(xt - w, y_topo),
			]),
			PackedColorArray([cor_poste]), PackedVector2Array([]))

#função para aleatoriade da pista
func _sortear_tipo(rng: RandomNumberGenerator) -> int:
	var total := 0.0
	for t in tipos_curva:
		total += tipos_curva[t]["peso"]
	var r := rng.randf() * total
	for t in tipos_curva:
		r -= tipos_curva[t]["peso"]
		if r <= 0.0:
			return t
	return TipoCurva.FRACA
	
#funções de desenhar e ajustar o barranco
func Draw_Barranco(b: LineData, t: LineData, i: int, cam_h: float, afina: float = 1.0) -> void:
	var it := posmod(i, linhas_totais)
	var ib := posmod(i - 1, linhas_totais)
	var lado : float = -lado_montanha[it]
	var f : float = minf(forca_montanha[it], forca_montanha[ib]) * afina
	if f < 0.02:
		return

	var neb := clampf((i - inicio_atual) / float(distancia_neblina), 0.0, 1.0) * 0.8
	var listra := 1.0 if (i / 6) % 2 == 0 else 0.92

	# V: distância ao longo da pista, em unidades do mundo
	var v_b := float(i - 1) * segmentos / tamanho_tile_barranco
	var v_t := float(i) * segmentos / tamanho_tile_barranco

	var n := maxi(faixas_rampa, 1)
	var prev_d := dist_barranco
	var prev_h := 0.0
	for k in range(1, n + 1):
		var u := float(k) / n
		var d := dist_barranco + largura_barranco * u
		var h := -queda_vale * f * pow(u, curva_rampa)

		# tinta: branco (textura original) escurecendo levemente para o fundo
		var cor := Color.WHITE.lerp(cor_rampa_fundo, u * escurecer_fundo_rampa) * listra
		cor.a = 1.0
		cor = cor.lerp(cor_neblina, neb)

		# U: largura lateral em unidades do mundo
		var u0 := (prev_d - dist_barranco) * largura_rua / tamanho_tile_barranco
		var u1 := (d - dist_barranco) * largura_rua / tamanho_tile_barranco

		var pts := PackedVector2Array([
			Vector2(b.cam_x + lado * b.cam_w * prev_d, _y_tela(b, prev_h, cam_h)),
			Vector2(t.cam_x + lado * t.cam_w * prev_d, _y_tela(t, prev_h, cam_h)),
			Vector2(t.cam_x + lado * t.cam_w * d,      _y_tela(t, h, cam_h)),
			Vector2(b.cam_x + lado * b.cam_w * d,      _y_tela(b, h, cam_h)),
		])
		var uvs := PackedVector2Array([
			Vector2(u0, v_b), Vector2(u0, v_t),
			Vector2(u1, v_t), Vector2(u1, v_b),
		])
		_quad_tex(pts, uvs, cor, tex_barranco)
		prev_d = d
		prev_h = h

	if preencher_fundo:
		var w := float(largura_total)
		var borda_tela := 0.0 if lado < 0.0 else w
		var yb := _y_tela(b, prev_h, cam_h)
		var yt := _y_tela(t, prev_h, cam_h)
		var cf := cor_fundo_vale.lerp(cor_neblina, neb)
		draw_primitive(
			PackedVector2Array([
				Vector2(b.cam_x + lado * b.cam_w * prev_d, yb),
				Vector2(t.cam_x + lado * t.cam_w * prev_d, yt),
				Vector2(borda_tela, yt),
				Vector2(borda_tela, yb),
			]),
			PackedColorArray([cf]), PackedVector2Array([]))
			
func _quad_tex(pts: PackedVector2Array, uvs: PackedVector2Array, cor: Color, tex: Texture2D) -> void:
	if tex == null:
		draw_primitive(pts, PackedColorArray([cor]), PackedVector2Array([]))
	else:
		draw_primitive(pts, PackedColorArray([cor]), uvs, tex)

# Próximas curvas a partir da fatia atual
func curvas_a_frente(qtd: int) -> Array:
	var res := []
	if curvas.is_empty():
		return res
	var atual := posmod(int(pos_atual / segmentos), linhas_totais)
	var idx := 0
	while idx < curvas.size() and curvas[idx]["ini"] <= atual:
		idx += 1
	for k in range(mini(qtd, curvas.size())):
		var j := (idx + k) % curvas.size()
		var volta := floori(float(idx + k) / curvas.size())
		var c : Dictionary = curvas[j]
		var dist : int = c["ini"] + volta * linhas_totais - atual
		res.append({
			"indice": j, "dist": dist, "tipo": c["tipo"],
			"forca": c["forca"], "tam": c["tam"],
			"editavel": dist > int(segmentos),   # fora da tela
		})
	return res


func substituir_curva(indice: int, tipo: int, lado: int) -> void:
	var c : Dictionary = curvas[indice]
	var ini : int = c["ini"]
	var cfg : Dictionary = tipos_curva[tipo]
	var tam_r : Vector2i = cfg["tamanho"]
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var tam : int = mini(rng.randi_range(tam_r.x, tam_r.y), linhas_totais - 30 - ini)
	if tam < 5:
		return

	# apaga a antiga e as seguintes que colidirem com a nova (todas fora da tela)
	_apagar_curva(c)
	var fim := ini + tam + 20
	while indice + 1 < curvas.size() and curvas[indice + 1]["ini"] < fim:
		_apagar_curva(curvas[indice + 1])
		curvas.remove_at(indice + 1)

	var sinal : int = lado if lado != 0 else (1 if rng.randf() < 0.5 else -1)
	var forca := _escrever_curva(ini, tam, tipo, sinal, rng)
	curvas[indice] = {"ini": ini, "tam": tam, "tipo": tipo, "forca": forca}

	centros_U.clear()
	for cv in curvas:
		if cv["tipo"] == TipoCurva.U:
			centros_U.append(int(cv["ini"] + cv["tam"] / 2))
	_aplicar_descida()
	_calcular_lados_montanha()

func _apagar_curva(c: Dictionary) -> void:
	for k in range(c["tam"]):
		lines[c["ini"] + k].curvatura = 0.0

# Perfil de curvatura ao longo da curva (t vai de 0 a 1)
func _perfil_curva(tipo: int, t: float) -> float:
	if tipo == TipoCurva.U:
		# entrada gradual, platô sustentado, saída gradual
		return smoothstep(0.0, 0.10, t) * (1.0 - smoothstep(0.90, 1.0, t))
	return sin(PI * t)


# Escreve a curva em lines[] e devolve a força (com sinal).
# A soma da curvatura = intensidade * heading_base, independente de tamanho e perfil.
func _escrever_curva(ini: int, tam: int, tipo: int, lado: int, rng: RandomNumberGenerator, sorteio: bool = true) -> float:
	var cfg : Dictionary = tipos_curva[tipo]
	var int_r : Vector2 = cfg["intensidade"]
	var intensidade := rng.randf_range(int_r.x, int_r.y) if sorteio else (int_r.x + int_r.y) * 0.5
	var heading := intensidade * heading_base

	var soma := 0.0
	for k in range(tam):
		soma += _perfil_curva(tipo, (k + 0.5) / tam)

	var forca := heading / soma * lado
	for k in range(tam):
		lines[ini + k].curvatura = forca * _perfil_curva(tipo, (k + 0.5) / tam)
	return forca
	
	
func _aplicar_descida() -> void:
	var n := linhas_totais

	# 1) inclinação desejada por fatia: base + reforço dentro das curvas
	var inc : Array[float] = []
	inc.resize(n)
	inc.fill(descida_base)
	for c in curvas:
		var ini : int = c["ini"]
		var tam : int = c["tam"]
		for k in range(tam):
			if ini + k < n:
				inc[ini + k] += descida_base * reforco_curva * sin(PI * (k + 0.5) / tam)

	# 2) suaviza a inclinação (média móvel) para não haver trocos bruscos
	var suave : Array[float] = []
	suave.resize(n)
	var r := suavizar_descida
	var soma := 0.0
	for k in range(-r, r + 1):
		soma += inc[clampi(k, 0, n - 1)]
	for i in range(n):
		suave[i] = soma / float(2 * r + 1)
		soma += inc[clampi(i + r + 1, 0, n - 1)] - inc[clampi(i - r, 0, n - 1)]
	var max_delta := descida_base * 0.02
	for i in range(1, n):
		suave[i] = clampf(suave[i], suave[i - 1] - max_delta, suave[i - 1] + max_delta)
	
	# 3) integra: a altura é a soma (negativa) das inclinações
	var h := 0.0
	for i in range(n):
		lines[i].y = h
		h -= suave[i]
	queda_volta = h
	y_suave.resize(n)
	var rr := suavizar_cume
	var s := 0.0
	for k in range(-rr, rr + 1):
		s += lines[clampi(k, 0, n - 1)].y
	for i in range(n):
		y_suave[i] = s / float(2 * rr + 1)
		s += lines[clampi(i + rr + 1, 0, n - 1)].y - lines[clampi(i - rr, 0, n - 1)].y
		
func _atualizar_parallax(c: float, delta: float) -> void:
	heading_mundo += c
	var sinal := -1.0 if inverter_parallax else 1.0
	for k in range(camadas.size()):
		var fator : float = fatores[k] if k < fatores.size() else 1.0
		var alvo := heading_mundo * fator * intensidade_parallax * sinal
		# suaviza para não tremer em mudanças bruscas de curvatura
		offset_camadas[k] = lerpf(offset_camadas[k], alvo, 1.0 - exp(-suavizar_parallax * delta))
		camadas[k].region_rect.position.x = offset_camadas[k]

func _hash01(i: int, sal: int) -> float:
	var h : int = (i * 73856093) ^ (sal * 19349663)
	h = (h ^ (h >> 13)) * 1274126177
	return float(h & 0xFFFF) / 65535.0


func Draw_Arvore(b: LineData, t: LineData, i: int, cam_h: float, afina: float) -> void:
	var it := posmod(i, linhas_totais)
	var lado : float = -lado_montanha[it]
	var f : float = forca_montanha[it] * afina
	if f < 0.05 or t.scale <= 0.0:
		return

	var neb : float = clampf((i - inicio_atual) / float(distancia_neblina), 0.0, 1.0) * 0.6
	var w : float = float(largura_total)
	var borda_tela : float = 0.0 if lado < 0.0 else w

	# massa escura de base: fecha o vão entre as árvores, do pé da rampa até a borda da tela
	if massa_floresta:
		var d0 : float = dist_arvore_min
		var h0 : float = -queda_vale * f * pow(clampf((d0 - dist_barranco) / largura_barranco, 0.0, 1.0), curva_rampa)
		var y_b0 : float = _y_tela(b, h0, cam_h)
		var y_t0 : float = _y_tela(t, h0, cam_h)
		var alt_m : float = altura_arvore * 0.55 * f
		var y_b1 : float = _y_tela(b, h0 + alt_m, cam_h)
		var y_t1 : float = _y_tela(t, h0 + alt_m, cam_h)
		var c_massa : Color = cor_massa.lerp(cor_neblina, neb)
		draw_primitive(
			PackedVector2Array([
				Vector2(b.cam_x + lado * b.cam_w * d0, y_b0),
				Vector2(t.cam_x + lado * t.cam_w * d0, y_t0),
				Vector2(borda_tela, y_t1),
				Vector2(borda_tela, y_b1)]),
			PackedColorArray([c_massa]), PackedVector2Array([]))

	# fileiras: da mais longe da pista para a mais perto (a mais perto fica por cima)
	for r in range(fileiras_arvore - 1, -1, -1):
		var fr : float = float(r) / maxf(fileiras_arvore - 1, 1)
		var jitter : float = _hash01(i, 10 + r)
		var d : float = lerpf(dist_arvore_min, dist_arvore_max, clampf(fr + (jitter - 0.5) * 0.5, 0.0, 1.0))
		var u : float = clampf((d - dist_barranco) / largura_barranco, 0.0, 1.0)
		var h_chao : float = -queda_vale * f * pow(u, curva_rampa)

		var x : float = t.cam_x + lado * t.cam_w * d
		var y_base : float = _y_tela(t, h_chao, cam_h)

		var esc : float = 0.8 + 0.8 * _hash01(i, 20 + r)
		var alt_px : float = y_base - _y_tela(t, h_chao + altura_arvore * esc * f, cam_h)
		if alt_px < 2.0:
			continue
		var larg_px : float = alt_px * largura_arvore

		# fileiras mais longe da pista ficam mais claras/azuladas (profundidade)
		var cor_f : Color = cor_arvore_escura.lerp(cor_arvore_clara, fr * 0.8 + _hash01(i, 30 + r) * 0.2)
		cor_f = cor_f.lerp(cor_neblina, neb)
		var cor_t : Color = cor_tronco.lerp(cor_neblina, neb)

		var tw : float = larg_px * 0.07
		var t_alt : float = alt_px * 0.16
		draw_primitive(
			PackedVector2Array([Vector2(x - tw, y_base), Vector2(x + tw, y_base),
				Vector2(x + tw, y_base - t_alt), Vector2(x - tw, y_base - t_alt)]),
			PackedColorArray([cor_t]), PackedVector2Array([]))

		for k in range(3):
			var fk : float = float(k) / 3.0
			var y_b : float = y_base - t_alt - (alt_px - t_alt) * fk * 0.75
			var y_t : float = y_b - (alt_px - t_alt) * 0.42
			var meia : float = larg_px * 0.5 * (1.0 - fk * 0.3)
			draw_primitive(
				PackedVector2Array([Vector2(x - meia, y_b), Vector2(x + meia, y_b), Vector2(x, y_t)]),
				PackedColorArray([cor_f]), PackedVector2Array([]))
