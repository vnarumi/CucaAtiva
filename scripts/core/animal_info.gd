class_name AnimalInfo
extends RefCounted
## Nome de exibição e descrição do som de cada animal — a "audiodescrição" que
## aparece como legenda quando o jogador acerta um par (acessibilidade: ajuda
## quem ouve mal e cobre os animais que ainda não têm arquivo de som).
## A chave é o nome do arquivo da foto, sem extensão (ex.: "leao_marinho").

const INFO := {
	# Fácil
	"vaca": ["Vaca", "Muuu!"],
	"porco": ["Porco", "Óinc, óinc!"],
	"gato": ["Gato", "Miau!"],
	"cachorro": ["Cachorro", "Au, au!"],
	"elefante": ["Elefante", "Trombeteia: Prrruuu!"],
	"leao": ["Leão", "Ruge: Rrroarr!"],
	"pato": ["Pato", "Quá, quá!"],
	"galinha": ["Galinha", "Có, có, có!"],
	"sapo": ["Sapo", "Croac, croac!"],
	"girafa": ["Girafa", "Quase não faz som"],
	"borboleta": ["Borboleta", "Voa em silêncio"],
	"peixe_dourado": ["Peixe-dourado", "Nada em silêncio"],
	# Médio
	"cavalo": ["Cavalo", "Relincha: Iiirrr!"],
	"ovelha": ["Ovelha", "Béééé!"],
	"urso": ["Urso", "Rosna: Grrrr!"],
	"jacare": ["Jacaré", "Ronca grave: Grrrum!"],
	"pombo": ["Pombo", "Arrulha: Ru-cu-cu!"],
	"coelho": ["Coelho", "Quase não faz som"],
	"golfinho": ["Golfinho", "Assobia: Iii-iii!"],
	"caranguejo": ["Caranguejo", "Estala as pinças: Clac, clac!"],
	"caracol": ["Caracol", "Desliza em silêncio"],
	"coala": ["Coala", "Ronco grave: Bruum!"],
	"hipopotamo": ["Hipopótamo", "Ronca alto: Hrum, hrum!"],
	"arara": ["Arara", "Grita: Ráá, ráá!"],
	"cabrito": ["Cabrito", "Mééé!"],
	"hamster": ["Hamster", "Guincha baixinho: Quic, quic!"],
	"leao_marinho": ["Leão-marinho", "Late: Ó-ó-ó!"],
	"tartaruga": ["Tartaruga", "Quase não faz som"],
	"coruja": ["Coruja", "Uuu, uuu!"],
	"macaco": ["Macaco", "Uh-uh, ah-ah!"],
	"zebra": ["Zebra", "Relincha: Iii-ó-ó!"],
	"pinguim": ["Pinguim", "Grasna: Ráá, ráá!"],
	# Difícil
	"cavalo_marinho": ["Cavalo-marinho", "Estala baixinho: Tic, tic!"],
	"porquinho_da_india": ["Porquinho-da-índia", "Guincha: Uiic, uiic!"],
	"esquilo": ["Esquilo", "Tchic, tchic!"],
	"pardal": ["Pardal", "Piu, piu!"],
	"canario": ["Canário", "Canta: Trili-li-li!"],
	"periquito": ["Periquito", "Piu, piu agudo!"],
	"chita": ["Chita", "Pia e ronrona: Ri-ri-ri!"],
	"tigre": ["Tigre", "Ruge: Rrroarr!"],
	"onca": ["Onça", "Rosna rouco: Rrrarr!"],
	"burro": ["Burro", "Zurra: I-ó, i-ó!"],
	"bezerro": ["Bezerro", "Muu, baixinho!"],
	"bufalo": ["Búfalo", "Muge grave: Muuu!"],
	"rinoceronte": ["Rinoceronte", "Bufa: Fuuf, fuuf!"],
	"tubarao": ["Tubarão", "Nada em silêncio"],
	"baleia": ["Baleia", "Canta grave: Uuuu-ooooo!"],
	"polvo": ["Polvo", "Nada em silêncio"],
	"vespa": ["Vespa", "Zumbe: Zzzzz!"],
	"arara_azul": ["Arara-azul", "Grita: Aaarr, aaarr!"],
	"spitz": ["Spitz", "Late fino: Au, au!"],
	"canguru": ["Canguru", "Grunhe baixinho: Chuc, chuc!"],
}


## Legenda de um animal a partir do caminho da foto
## (ex.: ".../vaca.jpg" -> "Vaca – Muuu!"). Animal sem cadastro devolve ""
## (nenhuma legenda).
static func caption(icon_path: String) -> String:
	var key := icon_path.get_file().get_basename()
	if not INFO.has(key):
		return ""
	var entry: Array = INFO[key]
	return "%s – %s" % [entry[0], entry[1]]
