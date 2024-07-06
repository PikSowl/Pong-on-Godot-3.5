extends Node2D

# states
enum GAME_STATE {MENU, SERVE, PLAY}
var isPlayerServe = true

#curent state
var currentGameState = GAME_STATE.MENU

# screen values
onready var screenWidth = get_tree().get_root().size.x
onready var screenHeight = get_tree().get_root().size.y
onready var halfScreenWidth = screenWidth / 2
onready var halfScreenHeight = screenHeight / 2

# padle variables
var paddleColor = Color.blue
var paddleSize = Vector2(10.0,100.0)
var halfPaddleHeight = paddleSize.y / 2
var paddlePadding = 10.0

# ball variables
var ballRadius = 10
var ballColor = Color.blue

# font variable
var scoreFont = DynamicFont.new()
var textFont = DynamicFont.new()
var robotoFile = load("res://Roboto-Light.ttf")
var textSize = 72
var scoreSize = 192
var halfWidthState
var heightText
var stateText 

# scoring
var playerScore = 0
var playerScoreText := playerScore as String
var playerTextHalfWidth
var playerScorePosition

var enemyScore = 0
var enemyScoreText := enemyScore as String
var enemyTextHalfWidth
var enemyScorePosition

const MAX_SCORE = 3
var isPlayerWin


# ball variables
onready var staringBallPosition = Vector2(halfScreenWidth,halfScreenHeight)
onready var ballPosition = staringBallPosition

# player variables
onready var playerPosition = Vector2(paddlePadding, halfScreenHeight - halfPaddleHeight)
onready var player : Rect2 = Rect2(playerPosition, paddleSize)

# enemy variables
onready var enemyPosition = Vector2(screenWidth - (paddlePadding + paddleSize.x), halfScreenHeight - halfPaddleHeight)
onready var enemy : Rect2 = Rect2(enemyPosition, paddleSize)

# string variable
var statePosition


# delta key
const RESET_DELTA_KEY = 0.0
const MAX_KEY_TIME = 0.3
var deltaKeyPress = 0.0

# ball speed
var startingSpeed = Vector2(400.0, 0.0)
var ballSpeed = startingSpeed

var playerSpeed = 200.0

func _ready() -> void:
	print(get_tree().get_root().size)
	textFont.font_data = robotoFile
	textFont.size = textSize
	
	scoreFont.font_data = robotoFile
	scoreFont.size = scoreSize
	
	heightText = halfScreenHeight + scoreFont.get_string_size(playerScoreText).y / 16 * 5
	
	playerTextHalfWidth = scoreFont.get_string_size(playerScoreText).x / 2
	playerScorePosition = Vector2(halfScreenWidth - halfScreenWidth/2 - playerTextHalfWidth, heightText)

	enemyTextHalfWidth = scoreFont.get_string_size(enemyScoreText).x / 2
	enemyScorePosition = Vector2(halfScreenWidth + halfScreenWidth/2 - enemyTextHalfWidth, heightText)
		
func _physics_process(delta: float) -> void:
	
	deltaKeyPress += delta
	
	match currentGameState:
		GAME_STATE.MENU:
			if(isPlayerWin == true):
				changeState("YOU WIN. SPACE TO WIN AGAIN")
			elif(isPlayerWin == false):
				changeState("YOU LOSE. SPACE TO IMPROVE")
			else:
				changeState("START WITH SPACE")
			if(Input.is_key_pressed(KEY_SPACE) and
			deltaKeyPress > MAX_KEY_TIME):	
				playerScore = 0
				enemyScore = 0
				playerScoreText = playerScore as String
				enemyScoreText = enemyScore as String
				currentGameState = GAME_STATE.SERVE
				deltaKeyPress = RESET_DELTA_KEY
		GAME_STATE.SERVE:
			setStartingPosition()
			update()
			
			if(MAX_SCORE == playerScore):
				isPlayerWin = true
				currentGameState = GAME_STATE.MENU
			elif(MAX_SCORE == enemyScore):
				isPlayerWin = false
				currentGameState = GAME_STATE.MENU
			
			if isPlayerServe:
				ballSpeed = startingSpeed
				changeState("SERVE WITH SPACE")
			
			if !isPlayerServe:
				ballSpeed = -startingSpeed
				changeState("WAIT FOR ENEMY SERVE")
			
			if(Input.is_key_pressed(KEY_SPACE)and
			deltaKeyPress > MAX_KEY_TIME):
				currentGameState = GAME_STATE.PLAY
				deltaKeyPress = RESET_DELTA_KEY
		GAME_STATE.PLAY:
			changeState("PLAY")
			if(Input.is_key_pressed(KEY_SPACE)and
			deltaKeyPress > MAX_KEY_TIME):
				currentGameState = GAME_STATE.SERVE
				deltaKeyPress = RESET_DELTA_KEY
				
			ballPosition += ballSpeed * delta
			
			if ballPosition.x <= 0:
				enemyScore += 1
				enemyScoreText = enemyScore as String
				currentGameState = GAME_STATE.SERVE
				deltaKeyPress = RESET_DELTA_KEY
				isPlayerServe = true
				
			if ballPosition.x >= screenWidth:
				playerScore += 1
				playerScoreText = playerScore as String
				currentGameState = GAME_STATE.SERVE
				deltaKeyPress = RESET_DELTA_KEY
				isPlayerServe = false
			
			if (ballPosition.y - ballRadius <= 0.0 or 
			ballPosition.y + ballRadius >= screenHeight):
				ballSpeed.y = -ballSpeed.y
			
			if(ballPosition.x - ballRadius >= playerPosition.x and
			ballPosition.x - ballRadius <= playerPosition.x + paddleSize.x):
				
				var paddleThird = paddleSize.y/3
				
				if (ballPosition.y >= playerPosition.y and
				ballPosition.y <= playerPosition.y + paddleThird):
					var tempBall = Vector2(-ballSpeed.x, - 400.0)
					ballSpeed = tempBall
				elif (ballPosition.y >= playerPosition.y + paddleThird and
				ballPosition.y <= playerPosition.y + 2 * paddleThird):
					var tempBall = Vector2(-ballSpeed.x, 0.0)
					ballSpeed = tempBall
				elif (ballPosition.y >= playerPosition.y + 2 * paddleThird and
				ballPosition.y <= playerPosition.y + paddleSize.y):
					var tempBall = Vector2(-ballSpeed.x, 400.0)
					ballSpeed = tempBall
				
			
			if(ballPosition.x + ballRadius >= enemyPosition.x and
			ballPosition.x + ballRadius <= enemyPosition.x + paddleSize.x):
				
				var paddleThird = paddleSize.y/3
				
				if (ballPosition.y >= enemyPosition.y and
				ballPosition.y <= enemyPosition.y + paddleThird):
					var tempBall = Vector2(-ballSpeed.x, - 400.0)
					ballSpeed = tempBall
				elif (ballPosition.y >= enemyPosition.y + paddleThird and
				ballPosition.y <= enemyPosition.y + 2 * paddleThird):
					var tempBall = Vector2(-ballSpeed.x, 0.0)
					ballSpeed = tempBall
				elif (ballPosition.y >= enemyPosition.y + 2 * paddleThird and
				ballPosition.y <= enemyPosition.y + paddleSize.y):
					var tempBall = Vector2(-ballSpeed.x, 400.0)
					ballSpeed = tempBall
				
			if(Input.is_key_pressed(KEY_W)):
				playerPosition.y -= playerSpeed * delta
				playerPosition.y = clamp(playerPosition.y, 0.0, screenHeight - paddleSize.y)
				player = Rect2(playerPosition, paddleSize)
			if(Input.is_key_pressed(KEY_S)):
				playerPosition.y += playerSpeed * delta
				playerPosition.y = clamp(playerPosition.y, 0.0, screenHeight - paddleSize.y)
				player = Rect2(playerPosition, paddleSize)
			
			if ballPosition.y > enemyPosition.y + (paddleSize.y / 2 + 10):
				enemyPosition.y += 300 * delta
			if ballPosition.y < enemyPosition.y + (paddleSize.y / 2 - 10):
				enemyPosition.y -= 300 * delta
			enemyPosition.y = clamp(enemyPosition.y, 0.0, screenHeight - paddleSize.y)
			
			enemy = Rect2(enemyPosition, paddleSize)
			
			update()

func changeState(newStateText):
	stateText = newStateText
	halfWidthState = textFont.get_string_size(stateText).x / 2
	heightText = textFont.get_height()
	statePosition = Vector2((halfScreenWidth - halfWidthState), heightText)
	update()

func _draw() -> void:
	draw_rect(player, paddleColor)
	draw_rect(enemy, paddleColor)
	draw_string(textFont, statePosition, stateText)
	draw_string(scoreFont, playerScorePosition, playerScoreText)
	draw_string(scoreFont, enemyScorePosition, enemyScoreText)
	draw_circle(ballPosition, ballRadius, ballColor)
	
func setStartingPosition():
	enemyPosition = Vector2(screenWidth - (paddlePadding + paddleSize.x),
	halfScreenHeight - halfPaddleHeight)
	enemy = Rect2(enemyPosition, paddleSize)
	
	playerPosition = Vector2(paddlePadding, halfScreenHeight - halfPaddleHeight)
	player = Rect2(playerPosition, paddleSize)
	
	ballPosition = staringBallPosition
	
