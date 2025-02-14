extends Node

#prelaod
var batu = preload("res://Scene/rintangan/batu.tscn")
var kayu = preload("res://Scene/rintangan/kayu.tscn")
var kelelawar = preload("res://Scene/rintangan/kelelawar.tscn")
var tong = preload("res://Scene/rintangan/tong.tscn")
var tipe_rintangan := [batu, kayu, tong]
var rintangan : Array
var kelelawar_tinggi := [530,630]

const Rogue_Mulai := Vector2i(300, 680)
const Camera_Mulai := Vector2i(4, 212)
var kesulitan
const kesulitan_tersulit : int = 2
var score : int
const PERUBAHAN_SCORE : int = 10
var SCORE_TERTINGGI : int 
var kecepatan : float
const MULAI_KECEPATAN : float = 3.0
const KECEPATAN_MAKSIMAL : float = 20.0
const VARIABEL_KECEPATAN : int = 5000
var besar_layar : Vector2i
var tinggi_tanah : int
var game_mulai : bool
var rintangan_terakhir

# Called when the node enters the scene tree for the first time.
func _ready():
	besar_layar = get_window().size
	tinggi_tanah = $Tanah.global_position.y
	$"COBA LAGI".get_node("Button").pressed.connect(game_baru)
	game_baru()

func game_baru():
	
	score = 0
	tampilkan_score()
	game_mulai = false
	get_tree().paused = false
	kesulitan = 0
	
	for rin in rintangan:
		rin.queue_free()
	rintangan.clear()
	
	$Rogue.position = Rogue_Mulai
	$Rogue.velocity = Vector2i(0, 0)
	$Camera2D.position = Camera_Mulai
	$Tanah.position = Vector2i(0, 0)
	
	$HUD.get_node("Tekan Spasi")
	$"COBA LAGI".hide()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if game_mulai:
		kecepatan = MULAI_KECEPATAN + score / VARIABEL_KECEPATAN
		if kecepatan > KECEPATAN_MAKSIMAL:
			kecepatan = KECEPATAN_MAKSIMAL
		penyesuaian_kesulitan()
		
		#memuncukan  rintangan
		muncul_rintangan()
		
		$Rogue.position.x += kecepatan
		$Camera2D.position.x += kecepatan
		
		score += kecepatan
		tampilkan_score()

		
		if $Camera2D.position.x - $Tanah.position.x > besar_layar.x * 1.5:
			$Tanah.position.x += besar_layar.x 
			
		for rin in rintangan:
			if rin.position.x < ($Camera2D.position.x - besar_layar.x):
				remove_rin(rin)
		
	else:
		if Input.is_action_just_pressed("ui_accept"):
			game_mulai = true
			$HUD.get_node("Tekan Spasi").hide()
	
func muncul_rintangan():
	if rintangan.is_empty() or rintangan_terakhir.position.x < score + randi_range(300,500):
		
		var rin_tipe = tipe_rintangan[randi() % tipe_rintangan.size()]
		var rin 
		var banyak_rintangan = kesulitan + 1
		for i in range(randi() % banyak_rintangan + 1):
			rin = rin_tipe.instantiate()
			var sprite =  rin.get_node("Sprite2D")
			var rintangan_tinggi = rin.get_node("Sprite2D").texture.get_height()
			var rintangan_besar = rin.get_node("Sprite2D").scale
			var rin_x : int = besar_layar.x + score + 100 + (i * 80)
			var rin_y : int = besar_layar.y - tinggi_tanah - (rintangan_tinggi * rintangan_besar.y / 2) + 85
			add_rin(rin, rin_x, rin_y)
			rintangan_terakhir = rin
			print("rintangan berhasil dibuat")
		if kesulitan == kesulitan_tersulit:
			if  (randi() % 2) == 0:
				rin = kelelawar.instantiate()
				var rin_x : int = besar_layar.x + score + 100
				var rin_y : int = kelelawar_tinggi[randi() % kelelawar_tinggi.size()]
				add_rin(rin, rin_x, rin_y)

func add_rin(rin, x, y):
	rin.position = Vector2i(x, y)
	rin.body_entered.connect(terkena_rin)
	add_child(rin)
	rintangan.append(rin)
	print("Rintangan berhasil ditambahkan:", rin, "di posisi:", rin.position)

func remove_rin(rin):
	rin.queue_free()
	rintangan.erase(rin)
	
func terkena_rin(body):
	if body.name == "Rogue":
		print("terkena hit")
		game_over()
	
func tampilkan_score():
	$HUD.get_node("Score Mulai").text = "SCORE:" + str(score / PERUBAHAN_SCORE)
	
func tampilan_score_tertinggi():
	if score > SCORE_TERTINGGI:
		SCORE_TERTINGGI = score
		$HUD.get_node("Score Tertinggi").text = "Score Tertinggi: " + str( SCORE_TERTINGGI / PERUBAHAN_SCORE)
	
func penyesuaian_kesulitan():
	kesulitan = score / VARIABEL_KECEPATAN
	if kesulitan > kesulitan_tersulit:
		kesulitan = kesulitan_tersulit
		
func game_over():
	tampilan_score_tertinggi()
	get_tree().paused = true
	game_mulai = false
	$"COBA LAGI".show()
