// INITIAL DATA
ArrayList crystals = new ArrayList();
int bgColor = 10;
color[][] colors = {{color(0, 150, 200), color(232, 79, 51)},
                    {color(17, 91, 192), color(183, 49, 101)},
                    {color(25, 204, 204), color(109, 107, 178)}};

// SETUP 
void setup() {
  colorMode(RGB, 255);
  size(1600, 1000);
  smooth();
}

// DRAW
void draw() {
  background(bgColor);
  for (int i = crystals.size()-1; i >= 0; i--) {
    Crystal crystal = (Crystal) crystals.get(i);
    crystal.breathe();
    // kill!!
    if (!crystal.alive()) {
      crystals.remove(i);
    }
  }
  randomDraw();
}

// PAUSE CONTROL
void keyPressed() {
 //code in draw should not be executed
 noLoop();
}

void keyReleased() {
 //code in draw should be executed
 loop();
}

// MOUSE CLICK AND DRAG CONTROL
float dx = 0;
float dy = 0;
float px = 0;
float py = 0;
float dLimit = 4;
float o = .6;
float easing = 0.02;

void mousePressed() {
  px = mouseX;
  py = mouseY;
}

void mouseReleased() {
  dx = mouseX-px;
  dy = mouseY-py;
  float d = random(3,(sqrt(sq(dx)+sq(dy)))/dLimit);
  int myColor = int(random(colors.length));
  float xsize = random(10, 50);
  float ysize = random(10, 50);
  float zsize = random(abs(xsize-ysize), abs(xsize-ysize)*2);
  float xpos = map(mouseX, 0, width, 0, 100);
  float ypos = map(mouseY, 0, height, 0, 100)-ysize/2;
  int sides = int(random(3, int(d/10)));
  crystals.add(new Crystal(colors[myColor][0], colors[myColor][1], xsize, ysize, zsize, xpos, ypos, sides, easing, o, d));
}

// RANDOM CRYSTAL DRAW
int timer = 0;
int timerLow = 10;
int timerHigh = 100;
int timerUp = int(random(timerLow, timerHigh));
float timerX = 2;
float timerY = 2;
void randomDraw() {
  if (timer >= timerUp) {
    float dxp = (mouseX-timerX)/dLimit;
    float dyp = (mouseY-timerY)/dLimit;
    timerX = mouseX;
    timerY = mouseY;
    float d = random(3,(sqrt(sq(dxp)+sq(dyp))));
    int myColor = int(random(colors.length));
    float xsize = random(10, 50);
    float ysize = random(10, 50);
    float zsize = random(abs(xsize-ysize), abs(xsize-ysize)*2);
    float xpos = random(100);
    float ypos = random(100);
    int sides = int(random(3, int(d/5)));
    crystals.add(new Crystal(colors[myColor][0], colors[myColor][1], xsize, ysize, zsize, xpos, ypos, sides, easing, o, d));
    timer = 0;
    timerUp = int(random(timerLow, timerHigh));
  }
  timer++;
}

// GETX AND GETY (mapping functions)
float getX(float x) {
  float newX = map(x, 0, 100, 0, width);
  return newX;
}
float getY(float y) {
  float newY = map(y, 0, 100, 0, height);
  return newY;
}

// CRYSTAL CLASS
class Crystal {
  // initial properties
  color c;
  color capC;
  float xsize;
  float ysize;
  float zsize;
  float xpos;
  float ypos;
  int sides;
  float easing;
  float opacity;
  float o;
  float randomness;
  // initialize the arrays
  float[] sidePoints = new float[1];
  float[] destPoints = new float[1];
  Crystal(color initC, color initCapC, float initXsize, float initYsize, float initZsize, float initXpos, float initYpos, int initSides, float initEasing, float initO, float initRandomness) {
    // ARGUMENT INPUT DATA
    c = initC;
    capC = initCapC;
    xsize = initXsize;
    ysize = initYsize;
    zsize = initZsize;
    xpos = initXpos;
    ypos = initYpos;
    sides = initSides;
    easing = initEasing;
    opacity = 140;
    o = initO;
    randomness = initRandomness;
    sidePoints = expand(sidePoints, sides*4);
    destPoints = expand(destPoints, sides*4);
    // RANDOMIZED DATA (crystal drawing coordinates)
    float x = xpos;
    float y = ypos;
    float dx;
    float dy;
    for (int i = 0; i < sides; i++) {
      // fill out sides-1
      if (i < sides-1) {
        dx = random(-(xsize/(sides-1)), xsize/(sides-1));
        dy = random(-(zsize/(sides-1)), zsize/(sides-1));
      } 
      else {
        // complete the last side
        dx = xpos-x;
        dy = ypos-y;
      }
      int ii = i*4;
      // storing the points for the sides of the crystal
      // cap points are also stored in here and accessed simply via ii and ii+1;
      sidePoints[ii] = x;
      sidePoints[ii+1] = y;
      sidePoints[ii+2] = x+dx;
      sidePoints[ii+3] = y+dy;
      x += dx;
      y += dy;
      // destPoint fuckery
      float rx = random(-randomness/2, randomness/2);
      float ry= random(-randomness/2, randomness/2);
      destPoints[ii] = sidePoints[ii]+rx;
      destPoints[ii+1] = sidePoints[ii+1]+ry;
    }
  }
  // LIVE METHOD (draws the crystal)
  void live () {
    // draw the bottom cap
    beginShape();
    fill(capC, opacity);
    noStroke();
    for (int i = 0; i < sides; i++) {
      int ii = i*4;
      vertex(getX(sidePoints[ii]), getY(sidePoints[ii+1]+ysize));
    }
    endShape();
    // draw the sides
    for (int i = 0; i < sides; i++) {
      int ii = i*4;
      beginShape();
      fill(c, opacity);
      noStroke();
      vertex(getX(sidePoints[ii]), getY(sidePoints[ii+1]));
      vertex(getX(sidePoints[ii+2]), getY(sidePoints[ii+3]));
      vertex(getX(sidePoints[ii+2]), getY(sidePoints[ii+3]+ysize));
      vertex(getX(sidePoints[ii]), getY(sidePoints[ii+1]+ysize));
      endShape();
    }
    // draw the top cap
    beginShape();
    fill(capC, opacity);
    noStroke();
    for (int i = 0; i < sides; i++) {
      int ii = i*4;
      vertex(getX(sidePoints[ii]), getY(sidePoints[ii+1]));
    }
    endShape();
  }
  // BREATHE METHOD (interacts w/ crystal points and sets life bounds)
  void breathe () {
    // easing motion
    for (int i = 0; i < sides; i++) {
      int ii = i*4;
      float dx = destPoints[ii]-sidePoints[ii];
      float dy = destPoints[ii+1]-sidePoints[ii+1];
      sidePoints[ii] += dx*easing;
      sidePoints[ii+1] += dy*easing;
      if (i < sides-1) {
        sidePoints[ii+2] = sidePoints[ii+4];
        sidePoints[ii+3] = sidePoints[ii+5];
      } 
      else {
        sidePoints[ii+2] = sidePoints[0];
        sidePoints[ii+3] = sidePoints[1];
      }
    }
    
    // slowly remove opacity
    opacity -= o;
    // draw the crystal
    live();
  }
  // TEST LIFE BY OPACITY
  boolean alive() {
    if (opacity > 0) {
      return true;
    } 
    else {
      return false;
    }
  }
}

