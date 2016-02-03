/*
-Make a main GameObject abstract class?

-Boundry should be changed to Platform, with a main abstract platform class, falling, mooving, and fixed subclasses
-Mover should become Ball

-Moving left and right has to work with a wind-like force, and not a change in velocity

-Make it look good at the end


*/

import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.dynamics.contacts.*;


Box2DProcessing box2d;

boolean[] keys = new boolean[512];


Ball ball;
Mover m;

// A list we'll use to track fixed objects
ArrayList<Boundary> boundaries;

float grav;
int numOfPlatforms;

void setup()
{
  size(1000, 700);
  smooth();
  
  numOfPlatforms = 10;
  grav = -10;
    box2d = new Box2DProcessing(this);
  box2d.createWorld();
  // No global gravity force
  box2d.setGravity(0, grav);
  box2d.listenForCollisions();
  
    m = new Mover(20, width/2, height - 20);

  boundaries = new ArrayList<Boundary>();


  //  ball = new Ball(50, width/2, height/2);r  //x, y, w, h, angle
  //X is Object's width/2 not 0 because object is dealt with from its CENTER
  //Y - h/2
  boundaries.add(new Boundary(width/2, height - 5, width, 10, 0)); 

  for (int i = 0; i < numOfPlatforms; i++)
  {
    float x, y, w, h, a;
    a = random(-0.2, 0.2);
    h = 10;
    w = random(50, 300);
    y =  (i * (height/ (numOfPlatforms+1) ) + (height/ ( numOfPlatforms + 1 ) ) ) ;
    x = random(w/2, 900);
    boundaries.add(new Boundary(x, y, w, h, a)); //X is width/2 not 0 because object is dealt with from its CENTER
  }
}


void draw()
{
  background(255);
  box2d.step();

  //  ball.display();

  //  Vec2 force = ball.attract(ball);
  //  ball.applyForce(force);
  //  Vec2 force = attract(m);
  //
  //  m.applyForce(force);

  for (Boundary wall : boundaries) {
    wall.display();
  }

  m.display();
  m.update();
}

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
  //If object 1 is a boundry, and object 2 is a mover, then
  if (o1.getClass() == Boundary.class && o2.getClass() == Mover.class)
  {
    Mover m1 = (Mover) o2;
    m1.jump();
    
  }
  else   if (o1.getClass() == Mover.class && o2.getClass() == Boundary.class)
  {
    Mover m1 = (Mover) o1;
    m1.jump();
    
  }
  
  
//  ||
//      o2.getClass() == Mover.class &&
//      o1.getClass() == Boundary.class
  
  
}

void endContact()
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




