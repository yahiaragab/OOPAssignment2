// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2012
// Box2DProcessing example

// A fixed boundary class (now incorporates angle)

class Token {

  // A boundary is a simple rectangle with x,y,width,and height
  float x;
  float y;
  float w = 30;
  float h = 30;
  float a;
  // But we also have to make a body for box2d to know about it
  Body body;

 Token(float x,float y) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;

    //define the body
    makeBody(x, y);
    
    //set user data
    body.setUserData(this);
  }

  // Draw the boundary, it doesn't move so we don't have to ask the Body for location
  void display() 
  {
    this.w = 30;
    this.h = 30;
    fill(0);
    stroke(0);
    strokeWeight(1);
    rectMode(CENTER);
    float a = body.getAngle();
    pushMatrix();
    translate(x,y);
    rotate(-a);
    rect(0,0,w,h);
    popMatrix();
  }

  
  void makeBody(float x, float y)
  {
        // Define the polygon
    PolygonShape sd = new PolygonShape();
    // Figure out the box2d coordinates
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2);
    // We're just a box
    sd.setAsBox(box2dW, box2dH);


    // Create the body
    BodyDef bd = new BodyDef();
    bd.type = BodyType.STATIC;

    bd.position.set(box2d.coordPixelsToWorld(x,y));
    body = box2d.createBody(bd);
    
    // Attached the shape to the body using a Fixture
    body.createFixture(sd,1);
    
  }


}//end Class

