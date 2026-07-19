import processing.serial.*;

Serial myPort;

// -----------------------------
// Joystick Values
// -----------------------------
int joyX = 512;
int joyY = 512;
int button = 0;

// -----------------------------
// Player
// -----------------------------
float playerX;
float playerY;

float playerSpeed = 6;

int health = 100;
int score = 0;

boolean gameOver = false;

// -----------------------------
// Arrays
// -----------------------------
ArrayList<Bullet> bullets = new ArrayList<Bullet>();
ArrayList<Enemy> enemies = new ArrayList<Enemy>();

// -----------------------------
// Enemy Spawn
// -----------------------------
int spawnTimer = 0;
int spawnDelay = 40;

// -----------------------------
// Fire Delay
// -----------------------------
int fireDelay = 0;

void setup()
{
  size(800,600);

  println(Serial.list());

  // CHANGE COM PORT IF NEEDED
  myPort = new Serial(this,"COM8",9600);
  myPort.bufferUntil('\n');

  playerX = width/2;
  playerY = height-70;

  textAlign(CENTER,CENTER);
}

void draw()
{
  background(0);

  drawStars();

  if(gameOver)
  {
    fill(255,0,0);
    textSize(45);
    text("GAME OVER",width/2,height/2-20);

    textSize(25);
    text("Final Score : "+score,width/2,height/2+30);

    text("Press R to Restart",width/2,height/2+80);
    return;
  }

  movePlayer();

  drawPlayer();

  drawHUD();

  // Remaining code comes in Part 3
  updateBullets();
  updateEnemies();
  checkCollisions();
  spawnEnemies();
  
}
void updateBullets() {

  if (button == 1 && fireDelay <= 0) {
    bullets.add(new Bullet(playerX, playerY - 25));

    myPort.write('F');     // Fire buzzer

    fireDelay = 12;
  }

  if (fireDelay > 0)
    fireDelay--;

  for (int i = bullets.size()-1; i >= 0; i--) {

    Bullet b = bullets.get(i);

    b.update();
    b.display();

    if (b.y < 0)
      bullets.remove(i);
  }
}

void spawnEnemies() {

  spawnTimer++;

  if (spawnTimer >= spawnDelay) {

    enemies.add(new Enemy(random(30, width-30), -20));

    spawnTimer = 0;

    if (spawnDelay > 15)
      spawnDelay--;
  }
}

void updateEnemies() {

  for (int i = enemies.size()-1; i >= 0; i--) {

    Enemy e = enemies.get(i);

    e.update();
    e.display();

    if (e.y > height + 20) {

      enemies.remove(i);

      health -= 10;

      myPort.write('H');

      updateLED();

      if (health <= 0) {

        myPort.write('X');

        gameOver = true;
      }
    }
  }
}

void checkCollisions() {

  for (int i = enemies.size()-1; i >= 0; i--) {

    Enemy e = enemies.get(i);

    for (int j = bullets.size()-1; j >= 0; j--) {

      Bullet b = bullets.get(j);

      if (dist(b.x, b.y, e.x, e.y) < 20) {

        bullets.remove(j);
        enemies.remove(i);

        score += 10;

        break;
      }
    }
  }
}
class Enemy {

  float x, y;

  float speed = 3;

  Enemy(float x, float y) {

    this.x = x;
    this.y = y;
  }

  void update() {

    y += speed;
  }

  void display() {

    rectMode(CENTER);

    fill(255, 0, 0);

    rect(x, y, 30, 30);

    fill(255);

    ellipse(x, y, 10, 10);
  }
}
class Bullet {

  float x, y;

  Bullet(float x, float y) {

    this.x = x;
    this.y = y;
  }

  void update() {

    y -= 10;
  }

  void display() {

    fill(255, 255, 0);

    ellipse(x, y, 6, 14);
  }
}
void updateLED() {

  if (health > 60)
    myPort.write('G');

  else if (health > 30)
    myPort.write('Y');

  else
    myPort.write('R');
}

// -----------------------------
// Move Player
// -----------------------------
void movePlayer()
{
  if(joyX<400)
    playerX-=playerSpeed;

  if(joyX>600)
    playerX+=playerSpeed;

  if(joyY<400)
    playerY-=playerSpeed;

  if(joyY>600)
    playerY+=playerSpeed;

  playerX=constrain(playerX,25,width-25);
  playerY=constrain(playerY,25,height-25);
}

// -----------------------------
// Draw Spaceship
// -----------------------------
void drawPlayer()
{
  pushMatrix();

  translate(playerX,playerY);

  fill(0,200,255);

  triangle(
    0,-25,
    -18,20,
    18,20
  );

  fill(255);

  ellipse(0,-5,10,10);

  fill(255,120,0);

  triangle(
    -8,20,
    8,20,
    0,35
  );

  popMatrix();
}

// -----------------------------
// Draw HUD
// -----------------------------
void drawHUD()
{
  fill(255);

  textSize(20);
  textAlign(LEFT);

  text("Score : "+score,20,30);

  noFill();
  stroke(255);

  rect(20,50,200,20);

  noStroke();

  if(health>60)
      fill(0,255,0);
  else if(health>30)
      fill(255,255,0);
  else
      fill(255,0,0);

  rect(20,50,health*2,20);
}

// -----------------------------
// Stars
// -----------------------------
void drawStars()
{
  stroke(255);

  for(int i=0;i<120;i++)
  {
    point(random(width),random(height));
  }

  noStroke();
}

// -----------------------------
// Serial Receive
// -----------------------------
void serialEvent(Serial p)
{
  String data=p.readStringUntil('\n');

  if(data==null)
    return;

  data=trim(data);

  String values[]=split(data,',');

  if(values.length==3)
  {
    joyX=int(values[0]);
    joyY=int(values[1]);
    button=int(values[2]);
  }
}

// -----------------------------
// Restart
// -----------------------------
void keyPressed()
{
  if(gameOver && (key=='r'||key=='R'))
  {
    score=0;
    health=100;
    bullets.clear();
    enemies.clear();

    playerX=width/2;
    playerY=height-70;

    gameOver=false;
  }
}
