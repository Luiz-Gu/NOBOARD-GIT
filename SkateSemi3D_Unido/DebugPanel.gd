extends CanvasLayer

const NOMES := ["Fraca", "Média", "Forte", "U"]

var main                      # sem tipo de propósito: aceita as variáveis do Main
var painel : PanelContainer
var lbl_avanco : Label
var lbl_vel : Label
var lbl_curvas : Label
var opt_tipo : OptionButton
var opt_lado : OptionButton
var _tempo := 0.0


func iniciar(m) -> void:
	main = m
	layer = 100

	painel = PanelContainer.new()
	painel.position = Vector2(10, 10)
	add_child(painel)

	var margem := MarginContainer.new()
	for lado in ["left", "top", "right", "bottom"]:
		margem.add_theme_constant_override("margin_" + lado, 8)
	painel.add_child(margem)

	var vb := VBoxContainer.new()
	vb.custom_minimum_size = Vector2(320, 0)
	margem.add_child(vb)

	_rotulo(vb, "DEBUG  (F1 esconde)")

	# ---- Módulo 1: velocidade ----
	lbl_avanco = _rotulo(vb, "")
	vb.add_child(_slider(0.0, 4.0, 0.05, main.vel_avanco, func(v): main.vel_avanco = v))
	

	vb.add_child(HSeparator.new())

	# ---- Módulo 2: próximas curvas ----
	_rotulo(vb, "Próximas curvas:")
	lbl_curvas = _rotulo(vb, "")
	_rotulo(vb, "Escolher a próxima:")

	opt_tipo = OptionButton.new()
	for nome in NOMES:
		opt_tipo.add_item(nome)
	opt_tipo.focus_mode = Control.FOCUS_NONE
	vb.add_child(opt_tipo)

	opt_lado = OptionButton.new()
	for nome in ["Lado aleatório", "Esquerda", "Direita"]:
		opt_lado.add_item(nome)
	opt_lado.focus_mode = Control.FOCUS_NONE
	vb.add_child(opt_lado)

	var btn := Button.new()
	btn.text = "Aplicar na próxima curva (fora da tela)"
	btn.focus_mode = Control.FOCUS_NONE
	btn.pressed.connect(_aplicar)
	vb.add_child(btn)


func _rotulo(pai: Node, texto: String) -> Label:
	var l := Label.new()
	l.text = texto
	pai.add_child(l)
	return l


func _slider(mn: float, mx: float, passo: float, valor: float, ao_mudar: Callable) -> HSlider:
	var s := HSlider.new()
	s.min_value = mn
	s.max_value = mx
	s.step = passo
	s.value = valor
	s.focus_mode = Control.FOCUS_NONE
	s.custom_minimum_size = Vector2(300, 20)
	s.value_changed.connect(ao_mudar)   # conecta depois de definir o valor
	return s


func _process(delta: float) -> void:
	if main == null or main.lines.is_empty():
		return
	lbl_avanco.text = "Avanço da pista: %.2fx  (~%d fatias/s)" % [
		main.vel_avanco, int(main.vel_avanco * Engine.get_frames_per_second())]

	_tempo += delta
	if _tempo < 0.1:
		return
	_tempo = 0.0
	_atualizar_curvas()


func _atualizar_curvas() -> void:
	var texto := ""
	var marcou := false
	for c in main.curvas_a_frente(4):
		var dir := "→ direita" if c["forca"] > 0.0 else "← esquerda"
		var marca := ""
		if c["editavel"] and not marcou:
			marca = "   ◄ alvo"
			marcou = true
		texto += "%s %s  em %d fatias%s\n" % [NOMES[c["tipo"]], dir, c["dist"], marca]
	lbl_curvas.text = texto


func _aplicar() -> void:
	for c in main.curvas_a_frente(6):
		if c["editavel"]:
			var lado : int = [0, -1, 1][opt_lado.selected]
			main.substituir_curva(c["indice"], opt_tipo.selected, lado)
			return


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F1:
		painel.visible = not painel.visible
