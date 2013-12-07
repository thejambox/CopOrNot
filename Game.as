package 
{
	import flash.display.*;
	import flash.events.*;
	
	import com.greensock.*;
	import com.greensock.easing.*;

	public class Game extends MovieClip
	{
		private const CORRECT_POINTS:int = 100;		// points awarded per correct answer
		private const WRONG_POINTS:int = -100;		// points awarded per wrong answer (likely negative)
		
		private const NUM_ROUNDS:int = 10;
		
		private const COP_PHOTOS:Array = [Cop1, Cop2, Cop3, Cop4, Cop5, Cop6, Cop7, Cop8, Cop9, Cop10];
		private const NOT_PHOTOS:Array = [Not1, Not2, Not3, Not4, Not5, Not6, Not7, Not8, Not9, Not10];
		
		private var score1:int;
		private var score2:int;
		
		private var round:int;
		
		private var gameOver:Boolean;
		private var roundOver:Boolean;
		
		private var roundAnswer:String;
		
		private var player1Win:Boolean;
		private var player2Win:Boolean;
		private var player1Loss:Boolean;
		private var player2Loss:Boolean;
		
		private var currentPhoto:MovieClip;
		
		public function Game()
		{
			// Constructor
		}

		public function init():void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownListener);
			
			startScreen.playButton.addEventListener(MouseEvent.CLICK, onPlayButtonClick);
			playAgainButton.addEventListener(MouseEvent.CLICK, onPlayAgainButtonClick);
			
			Audio.play(PoliceSound);
		}
		
		private function onPlayButtonClick(e:MouseEvent):void
		{
			startScreen.playButton.removeEventListener(MouseEvent.CLICK, onPlayButtonClick);
			
			initGame();
		}
		
		private function onPlayAgainButtonClick(e:MouseEvent):void
		{
			initGame();
		}
		
		private function initGame():void
		{
			Audio.play(IntroSound);
			
			score1 = 0;
			score2 = 0;
			round = 1;
			
			roundResultText.visible = false;
			playAgainButton.visible = false;
			
			updateScore();
			updateRound();
			
			winResult.visible = false;

			gameOver = false;
			
			startScreen.visible = false;
			
			nextRound();
		}
		
		private function updateScore():void
		{
			score1Text.text = "Score: " + score1;
			score2Text.text = "Score: " + score2;
		}
		
		private function updateRound():void
		{
			roundText.text = "Round " + round + " of " + NUM_ROUNDS;
		}
		
		private function nextRound():void
		{
			if (currentPhoto)
			{
				photoContainer.removeChild(currentPhoto);
			}
			
			var lastPhoto:MovieClip = currentPhoto;
			
			if (Utils.chance(50))
			{
				currentPhoto = new COP_PHOTOS[Utils.rndInt(COP_PHOTOS.length)]();
				
				while (lastPhoto != null && currentPhoto.toString() == lastPhoto.toString())
				{
					currentPhoto = new COP_PHOTOS[Utils.rndInt(COP_PHOTOS.length)]();
				}
				
				photoContainer.addChild(currentPhoto);
				roundAnswer = "Cop";
			}
			else
			{
				currentPhoto = new NOT_PHOTOS[Utils.rndInt(NOT_PHOTOS.length)]()
				
				while (lastPhoto != null && currentPhoto.toString() == lastPhoto.toString())
				{
					currentPhoto = new NOT_PHOTOS[Utils.rndInt(NOT_PHOTOS.length)]()
				}
				
				photoContainer.addChild(currentPhoto);
				roundAnswer = "Not";
			}
			
			player1Win = false;
			player2Win = false;
			player1Loss = false;
			player2Loss = false;
			
			roundOver = false;			
			
			TweenMax.from(currentPhoto, 1.0, {startAt:{x:320, y:175}, x:Utils.rndRange(500, 1000) * Utils.rndSign(), y:Utils.rndRange(500, 1000) * Utils.rndSign(), ease:Sine.easeOut, onComplete:tweenInComplete});
		}
		
		private function tweenInComplete():void
		{
			
		}
		
		private function tweenOutComplete():void
		{
			evalNextRound();
		}
		
		private function keyDownListener(e:KeyboardEvent):void
		{
			if (!(gameOver || roundOver))
			{
				switch(e.keyCode)
				{
					case 65:	// A = Cop guess for player 1
						if (roundAnswer == "Cop")
						{
							score1 += CORRECT_POINTS;
							player1Win = true;
							Audio.play(PoliceSound);
							updateScore();
						}
						else
						{
							score1 += WRONG_POINTS;
							player1Loss = true;
							Audio.play(WrongSound);
							updateScore();
						}
						break;
					case 90:	// Z = Not guess for player 1
						if (roundAnswer == "Not")
						{
							score1 += CORRECT_POINTS;
							player1Win = true;
							Audio.play(HornSound);
							updateScore();
						}
						else
						{
							score1 += WRONG_POINTS;
							player1Loss = true;
							Audio.play(WrongSound);
							updateScore();
						}
						break;
					case 75:	// K = Cop guess for player 2
						if (roundAnswer == "Cop")
						{
							score2 += CORRECT_POINTS;
							player2Win = true;
							Audio.play(PoliceSound);
							updateScore();
						}
						else
						{
							score2 += WRONG_POINTS;
							player2Loss = true;
							Audio.play(WrongSound);
							updateScore();
						}
						break;
					case 77:	// M = Not guess for player 2
						if (roundAnswer == "Not")
						{
							score2 += CORRECT_POINTS;
							player2Win = true;
							Audio.play(HornSound);
							updateScore();
						}
						else
						{
							score2 += WRONG_POINTS;
							player2Loss = true;
							Audio.play(WrongSound);
							updateScore();
						}
						break;
				}
				
				if (player1Win || player2Win || player1Loss || player2Loss)
				{
					roundOver = true;
					
					if (player1Win || player2Win)
					{
						var xTarget:int = -320;
						
						roundResultText.text = "PLAYER 1\nCORRECT!\n+" + CORRECT_POINTS;
												
						if (player2Win)
						{
							xTarget = 700+320;
							
							roundResultText.text = "PLAYER 2\nCORRECT!\n+" + CORRECT_POINTS;
						}
						TweenMax.to(currentPhoto, 1.0, {x:xTarget, y:"-175", scaleX:0.1, scaleY:0.1, rotation:720, ease:Sine.easeIn, onComplete:tweenOutComplete});
					}
					else
					{
						xTarget = -320;
						
						roundResultText.text = "PLAYER 1\nWRONG!\n" + WRONG_POINTS;
						
						if (player2Loss)
						{
							xTarget = 700+320;
							
							roundResultText.text = "PLAYER 2\nWRONG!\n" + WRONG_POINTS;
						}
						TweenMax.to(currentPhoto, 1.0, {x:xTarget, y:"700", scaleX:0.1, scaleY:0.1, rotation:Utils.rndSym(30), ease:Sine.easeIn, onComplete:tweenOutComplete});
					}
					
					roundResultText.visible = true;
				}
			}
		}
		
		private function evalNextRound():void
		{
			if (round == NUM_ROUNDS)
			{
				gameOver = true;
				
				roundResultText.visible = false;
				
				var winString:String;
				if (score1 > score2)
				{
					winString = "Player 1 Wins!";
				}
				else if (score1 < score2)
				{
					winString = "Player 2 Wins!";
				}
				else
				{
					winString = "It's A Tie!";
				}
				
				winResult.winText.text = winString;
				winResult.winTextBG1.text = winString;
				winResult.winTextBG2.text = winString;
				winResult.visible = true;
				
				playAgainButton.visible = true;
			}
			else
			{
				round++;
				updateRound();
				nextRound();
			}
		}
	}
}