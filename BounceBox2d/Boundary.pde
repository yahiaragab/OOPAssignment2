// A parent boundary class
class Boundary {

  // A boundary is a simple rectangle with x,y,width,and height
  float x;
  float y;
  float w;
  float h;
  color col;
  // But we also have to make a body for box2d to know about it
  Body body;

  Boundary(float x, float y, float w, float h, float a) 
  {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;

    //define the body
    makeBody(x, y, w, h, a);

    //set user data
    body.setUserData(this);
  }

  // This function removes the particle from the box2d world
  void killBody() 
  {
    box2d.destroyBody(body);
  }



  // Draw the boundary, it doesn't move so we don't have to ask the Body for location
  void display(color col) 
  {
    Vec2 pos = box2d.getBodyPixelCoord(body);

    fill(col);
    stroke(col);
    strokeWeight(1);
    rectMode(CENTER);
    float a = body.getAngle();
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-a);
    rect(0, 0, w, h);
    popMatrix();
  }


  void makeBody(float x, float y, float w, float h, float a)
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
    bd.angle = a;
    bd.position.set(box2d.coordPixelsToWorld(x, y));
    body = box2d.createBody(bd);

    // Attached the shape to the body using a Fixture
    body.createFixture(sd, 1);
  }
}//end Class

