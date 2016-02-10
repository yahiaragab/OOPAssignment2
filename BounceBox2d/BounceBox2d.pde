/*
-Make a main GameObject abstract class?
 
 -Boundry should be changed to Platform, with a main abstract platform class, falling, mooving, and fixed subclasses
 -Ball should become Ball
 
 -Moving left and right has to work with a wind-like force, and not a change in velocity
 
 -Make it look good at the end
 
 
 */

//importing all box2d files needed
import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.dynamics.contacts.*;

Box2DProcessing box2d;

//importing controlP5 library for buttons
import controlP5.*;
ControlP5 controlP5;

//declaring global variables
ArrayList<controlP5.Button> buttons = new ArrayList<controlP5.Button>();
DropdownList ddl;
PFont btnfont = createFont("Arial", 30, false); // use true/false for smooth/no-smooth
ControlFont btnFont = new ControlFont(btnfont, 241);
PFont headfont = createFont("Times", 15, false); // use true/false for smooth/no-smooth
ControlFont headFont = new ControlFont(headfont, 241);

//importing sound library
import ddf.minim.*;

AudioPlayer bounceSound;
AudioPlayer bell;
Minim minim;//audio context





boolean[] keys = new boolean[512];


Ball ball;
Floor floor;
Goal goal;

// A list we'll use to track fixed objects
ArrayList<Platform> platforms;
ArrayList<ExtraTime> extratime;
ArrayList<LessTime> lesstime;

float speed = 1000;
float left = speed * -1;
float right = speed;

float grav;
int numOfPlatforms;
boolean startGame = false;

float jumpHeight = 350;
float movVel = jumpHeight;
boolean jumpCompleted = false;

PImage img;

void setup()
{
  size(1000, 700);
  smooth();

  img = loadImage("background1.jpg");

  minim = new Minim(this);
  bounceSound = minim.loadFile("bounce.mp3", 5048);
  bell = minim.loadFile("bell.mp3", 5048);

  numOfPlatforms = 7;
  grav = -20;

  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  // No global gravity force
  box2d.setGravity(0, grav);
  box2d.listenForCollisions();

  ball = new Ball(20, width/2, height - 20);
  floor = new Floor(width/2, height - 5, width, 10, 0);
  //  goal = new Goal(width/2, 5, width, 10, 0);

  platforms = new ArrayList<Platform>();
  extratime = new ArrayList<ExtraTime>();
  lesstime = new ArrayList<LessTime>();

  //  ball = new Ball(50, width/2, height/2);r  //x, y, w, h, angle
  //X is Object's width/2 not 0 because object is dealt with from its CENTER
  //Y - h/2
  //  platforms.add(new Platform(width/2, height - 5, width, 10, 0)); 
  generateMap();
}

int mode = 0; 
float levelTime = 30;
float time = levelTime;
int points = 0;

void draw()
{
  box2d.step();
  background(255);
  
  switch (mode)
  {
  case 0:
    startGame = false;
    loop();
    mainMenu();
    break;

  case 1:
    loop();
    startGame();
    break;

  case 2:
    loop();
    instructions();
    break;

  case 3:
    

  default:
    gameOver();
    break;
  }

  hideButton();
}

int mainBtns;
void instructions()
{
}

void pause()
{
}

void gameOver()
{
  
}

void mainMenu()
{
  background(200);
  controlP5 = new ControlP5(this);

  image(img, -300, -150);

  //options on buttons in main menu
  String[] mainMsg = 
  {
    "Quit", "Start Game", "Instructions", "Leaderboards"
  }; 

  //add buttons to array list buttons
  int padding = 300;
  int w = (int)textWidth(mainMsg[0]) + padding;
  int h = 50;
  //return to main menu button. (value 100)
  buttons.add( controlP5.addButton(mainMsg[0], 0, 0, 0, (int)textWidth(mainMsg[0]), 20) );

  //other options
  for (int i = 1; i < mainMsg.length; i++)
  {
    int x = width/2 - (w/2);
    int y = ( height / mainMsg.length) * i;
    buttons.add( controlP5.addButton(mainMsg[i], i, x, y, w, h) );
    buttons.get(i).getCaptionLabel().setFont(btnfont);
  }

  mainBtns = mainMsg.length;
}



void startGame()
{
  if (!startGame)
  {
    ball.restart();
    time = levelTime;
    points = 0;
    startGame = true;
  }
  
  textSize(15);
  text(time, width/2, 15);
  text(points, 3*width/4, 15);
  
  if (frameCount % 60 == 0)
  {
    time--;
    
  }
  if (time == 0)
  {
    gameOver();
  }
  
  for (Platform wall : platforms) 
  {
    wall.display();
  }

  for (ExtraTime extra : extratime) 
  {
    extra.display();
  }

  for (LessTime less : lesstime) 
  {
    less.display();
  }

  ball.display();
  ball.update();
  floor.display();
  //    goal.display();

  if (keys['A'])
  {
    Vec2 wind = new Vec2(left, -50);
    ball.applyForce(wind);
  }
  if (keys['D'])
  {
    Vec2 wind = new Vec2(right, -50);
    ball.applyForce(wind);
  }
}


//deals with values returned from buttons
void controlEvent(ControlEvent theEvent)
{
  mode = (int)theEvent.getValue();
  println(theEvent.getValue());
}//control event

//hiding and showing buttons
void hideButton() 
{
  //if on main menu
  if (mode == 0) 
  {
    //hide quit
    buttons.get(0).hide();

    //show all other buttons
    for (int i = 1; i < buttons.size (); i++)
    {
      if (i < mainBtns)
      {
        buttons.get(i).show();
      }//end if
      else
      {
        buttons.get(i).hide();
      }//end else
    }//end for
  }//end if
  else 
  {
    for (int i = 1; i < buttons.size (); i++)
    {
      if (i < mainBtns)
      {
        buttons.get(i).hide();
      }//end if
    }//end for
    buttons.get(0).show();
  }//end else
}//end hide button



//GENERATE AND CLEAR MAP


void generateMap()
{
  background(255);
  float x, y, w, h, a, prevX = 0;
  float diff = 40;
  for (int i = 0; i < numOfPlatforms; i++)
  {
    w = random(100, 350)+ (40 * random(-1, 1) );
    x = random(w/2, 900) + (40 * random(-1, 1) );
    y =  (i * (height/ (numOfPlatforms+1) ) + (height/ ( numOfPlatforms + 1 ) ) ) ;
    h = 10;
    a = random(-0.2, 0.2);

//    if ( x > prevX - diff && x < prevX + diff)
//    {
//      w += (diff * 2);
//      if (x > 900)
//      {
//        x -= diff * 3;
//      }
//    }
//    prevX = x;
    platforms.add(new Platform(x, y, w, h, a)); //X is width/2 not 0 because object is dealt with from its CENTER

    //    generateTokens(a, y, w, h, a);
  }//end for
}//end generateMap()

void generateTokens(float x, float y, float w, float h, float a)
{
  int collectable = (int) random(0, 5);
  float tokenFloat = h + 15;
  float tokenW = 30;
  float tokenH = 30;

  switch (collectable)
  {
  case 0:
    extratime.add(new ExtraTime(x, y - tokenFloat, tokenW, tokenH, a));
    break;
  case 1:
    lesstime.add(new LessTime(x, y - tokenFloat, tokenW, tokenH, a));
    break;
  default:
    break;
  }//end switch
}


void clearMap()
{

  for (int i = 0; i < platforms.size (); i++)
  {

    platforms.get(i).killBody();
    platforms.remove(i);
    //    box2d.destroyBody(b.body);
  }

  for (int i = 0; i < extratime.size (); i++)
  {

    extratime.get(i).killBody();
    extratime.remove(i);
    //    box2d.destroyBody(b.body);
  }

  for (int i = 0; i < lesstime.size (); i++)
  {

    lesstime.get(i).killBody();
    lesstime.remove(i);
    //    box2d.destroyBody(b.body);
  }
}//end clearMap()




//cp tells which fixtures collided
//a fixture is the entity that attaches the SHAPE to the BODY. 
//SHAPE is the thing that has geometry. TWO SHAPES come in contact with each other 
//fixtures are used in this method.
void beginContact(Contact cp)
{
  //which fixtures have collided?
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();

  //which body are you attached to?
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();

  //which "Particle" is associated with that body? //ASSIGN USER DATA. setUserData(), getUserData() 
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();


  //User data doesn't determine TYPE of body
  //If object 1 is a boundary, and object 2 is a Ball, then
  if (o1.getClass() == Platform.class && o2.getClass() == Ball.class
    ||
    o1.getClass() == Ball.class && o2.getClass() == Platform.class)
  {
    Ball m1 = (Ball) o2;
    Platform m2 = (Platform) o1;

    m1.jump();

    if (startGame)
    {
      bounceSound.play();
      bounceSound.rewind();
    }
  }//end if ball and platform collision 


  if (o1.getClass() == Floor.class && o2.getClass() == Ball.class
    ||
    o1.getClass() == Ball.class && o2.getClass() == Floor.class)
  {
    Ball m1 = (Ball) o2;

    m1.jump();

    if (startGame)
    {
      bounceSound.play();
      bounceSound.rewind();
    }
  }

  if (o1.getClass() == Goal.class && o2.getClass() == Ball.class
    ||
    o1.getClass() == Ball.class && o2.getClass() == Goal.class)
  {
    Ball m1 = (Ball) o2;

    if (startGame)
    {
      bell.play();
      bell.rewind();
    }

    m1.restart();
  }


  if (o1.getClass() == ExtraTime.class && o2.getClass() == Ball.class
    ||
    o1.getClass() == Ball.class && o2.getClass() == ExtraTime.class)
  {
    Ball m1 = (Ball) o2;

    m1.jump();
  }

  if (o1.getClass() == LessTime.class && o2.getClass() == Ball.class
    ||
    o1.getClass() == Ball.class && o2.getClass() == LessTime.class)
  {
    Ball m1 = (Ball) o2;

    m1.jump();
  }
}//end beginContact()

void endContact(Contact cp)
{
}


void keyPressed()
{
  keys[keyCode] = true;
}

void keyReleased()
{
  keys[keyCode] = false;
}

