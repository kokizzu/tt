/*
 * $Id: shape.d,v 1.2 2004/11/12 14:46:01 kenta Exp $
 *
 * Copyright 2004 Kenta Cho. Some rights reserved.
 */
module abagames.tt.shape;

import abagames.util.gl;
import abagames.util.math;
import abagames.util.vector;
import abagames.util.rand;
import abagames.util.sdl.screen3d;
import abagames.tt.screen;
import abagames.tt.particle;

/**
 * Interface for drawing a shape.
 */
public interface Drawable {
  public void draw();
}

/**
 * Interface and implmentation for shape that has a collision.
 */
public interface Collidable {
  public Vector collision();
  public bool checkCollision(float ax, float ay, Collidable shape = null, float speed = 1);
}

private template CollidableImpl() {
  public bool checkCollision(float ax, float ay, Collidable shape = null, float speed = 1) {
    float cx, cy;
    if (shape) {
      cx = collision.x + shape.collision.x;
      cy = collision.y + shape.collision.y;
    } else {
      cx = collision.x;
      cy = collision.y;
    }
    cy *= speed;
    if (ax <= cx && ay <= cy)
      return true;
    else
      return false;
  }
}

/**
 * Enemy and my ship shape.
 */
public class ShipShape: Collidable, Drawable {
  mixin CollidableImpl;
 public:
  static enum Type {
    SMALL, MIDDLE, LARGE
  }
 private:
  static Rand rand;
  Structure[] structure;
  Vector _collision;
  float[] rocketX;
  Vector rocketPos, fragmentPos;
  int color;

  public static void setRandSeed(long n) {
    if (!rand) {
      rand = new Rand;
    }
    rand.setSeed(n);
  }

  public void create(long seed, Type type, bool damaged = false) {
    auto localRand = new Rand;
    localRand.setSeed(seed);
    final switch (type) {
    case Type.SMALL:
      createSmallType(localRand, damaged);
      break;
    case Type.MIDDLE:
      createMiddleType(localRand, damaged);
      break;
    case Type.LARGE:
      createLargeType(localRand, damaged);
      break;
    }
    rocketPos = new Vector;
    fragmentPos = new Vector;
  }

  private void createSmallType(Rand localRand, bool damaged = false) {
    _collision = new Vector;
    int shaftNum = 1 + localRand.nextInt(2);
    float sx = 0.25 + localRand.nextFloat(0.1);
    float so = 0.5 + localRand.nextFloat(0.3);
    float sl = 0.7 + localRand.nextFloat(0.9);
    float sw = 1.5 + localRand.nextFloat(0.7);
    sx *= 1.5f;
    so *= 1.5f;
    sl *= 1.5f;
    sw *= 1.5f;
    float sd1 = localRand.nextFloat(1) * PI / 3 + PI / 4;
    float sd2 = localRand.nextFloat(1) * PI / 10;
    int cl = localRand.nextInt(cast(int)Structure.COLOR_RGB.length - 2) + 2;
    color = cl;
    int shp = localRand.nextInt(Structure.Shape.ROCKET);
    switch (shaftNum) {
    case 1:
      structure ~= createShaft(localRand, 0, 0, so, sd1, sl, 2, sw, sd1 / 2, sd2, cl, shp, 5, 1, damaged);
      _collision.x = so / 2 + sw;
      _collision.y = sl / 2;
      rocketX ~= 0;
      break;
    case 2:
      structure ~= createShaft(localRand, sx, 0, so, sd1, sl, 1, sw, sd1 / 2, sd2, cl, shp, 5, 1, damaged);
      structure ~= createShaft(localRand, sx, 0, so, sd1, sl, 1, sw, sd1 / 2, sd2, cl, shp, 5, -1, damaged);
      _collision.x = sx + so / 2 + sw;
      _collision.y = sl / 2;
      rocketX ~= sx * 0.05;
      rocketX ~= -sx * 0.05;
      break;
    default: break;
    }
    _collision.x *= 0.1;
    _collision.y *= 1.2;
  }

  private void createMiddleType(Rand localRand, bool damaged = false) {
    _collision = new Vector;
    int shaftNum = 3 + localRand.nextInt(2);
    float sx = 1.0 + localRand.nextFloat(0.7);
    float so = 0.9 + localRand.nextFloat(0.6);
    float sl = 1.5 + localRand.nextFloat(2.0);
    float sw = 2.5 + localRand.nextFloat(1.4);
    sx *= 1.6f;
    so *= 1.6f;
    sl *= 1.6f;
    sw *= 1.6f;
    float sd1 = localRand.nextFloat(1) * PI / 3 + PI / 4;
    float sd2 = localRand.nextFloat(1) * PI / 10;
    int cl = localRand.nextInt(cast(int)Structure.COLOR_RGB.length - 2) + 2;
    color = cl;
    int shp = localRand.nextInt(Structure.Shape.ROCKET);
    switch (shaftNum) {
    case 3:
      int cshp = localRand.nextInt(Structure.Shape.ROCKET);
      structure ~= createShaft(localRand, 0, 0, so * 0.5, sd1, sl, 2, sw, sd1, sd2, cl, cshp, 8, 1, damaged);
      structure ~= createShaft(localRand, sx, 0, so, sd1, sl * 0.8, 1, sw, sd1 / 2, sd2, cl, shp, 5, 1, damaged);
      structure ~= createShaft(localRand, sx, 0, so, sd1, sl * 0.8, 1, sw, sd1 / 2, sd2, cl, shp, 5, -1, damaged);
      _collision.x = sx + so / 2 + sw;
      _collision.y = sl / 2;
      rocketX ~= 0;
      rocketX ~= sx * 0.05;
      rocketX ~= -sx * 0.05;
      break;
    case 4:
      structure ~= createShaft(localRand, sx / 3, -sx / 2, so, sd1, sl * 0.7, 1, sw * 0.6, sd1 / 3, sd2 / 2, cl, shp, 5, 1);
      structure ~= createShaft(localRand, sx / 3, -sx / 2, so, sd1, sl * 0.7, 1, sw * 0.6, sd1 / 3, sd2 / 2, cl, shp, 5, -1);
      structure ~= createShaft(localRand, sx, 0, so, sd1, sl, 1, sw, sd1 / 2, sd2, cl, shp, 5, 1, damaged);
      structure ~= createShaft(localRand, sx, 0, so, sd1, sl, 1, sw, sd1 / 2, sd2, cl, shp, 5, -1, damaged);
      _collision.x = sx + so / 2 + sw;
      _collision.y = sl / 2;
      rocketX ~= sx * 0.025;
      rocketX ~= -sx * 0.025;
      rocketX ~= sx * 0.05;
      rocketX ~= -sx * 0.05;
      break;
    default: break;
    }
    _collision.x *= 0.1;
    _collision.y *= 1.2;
  }

  private void createLargeType(Rand localRand, bool damaged = false) {
    _collision = new Vector;
    int shaftNum = 5 + localRand.nextInt(2);
    float sx = 3.0 + localRand.nextFloat(2.2);
    float so = 1.5 + localRand.nextFloat(1.0);
    float sl = 3.0 + localRand.nextFloat(4.0);
    float sw = 5.0 + localRand.nextFloat(2.5);
    sx *= 1.6f;
    so *= 1.6f;
    sl *= 1.6f;
    sw *= 1.6f;
    float sd1 = localRand.nextFloat(1) * PI / 3 + PI / 4;
    float sd2 = localRand.nextFloat(1) * PI / 10;
    int cl = localRand.nextInt(cast(int)Structure.COLOR_RGB.length - 2) + 2;
    color = cl;
    int shp = localRand.nextInt(Structure.Shape.ROCKET);
    switch (shaftNum) {
    case 5:
      int cshp = localRand.nextInt(Structure.Shape.ROCKET);
      structure ~= createShaft(localRand, 0, 0, so * 0.5, sd1, sl, 2, sw, sd1, sd2, cl, cshp, 8, 1, damaged);
      structure ~= createShaft(localRand, sx * 0.6, 0, so, sd1, sl * 0.6, 1, sw, sd1 / 3, sd2 / 2, cl, shp, 5, 1, damaged);
      structure ~= createShaft(localRand, sx * 0.6, 0, so, sd1, sl * 0.6, 1, sw, sd1 / 3, sd2 / 2, cl, shp, 5, -1, damaged);
      structure ~= createShaft(localRand, sx, 0, so, sd1, sl * 0.9, 1, sw, sd1 / 2, sd2, cl, shp, 5, 1, damaged);
      structure ~= createShaft(localRand, sx, 0, so, sd1, sl * 0.9, 1, sw, sd1 / 2, sd2, cl, shp, 5, -1, damaged);
      _collision.x = sx + so / 2 + sw;
      _collision.y = sl / 2;
      rocketX ~= 0;
      rocketX ~= sx * 0.03;
      rocketX ~= -sx * 0.03;
      rocketX ~= sx * 0.05;
      rocketX ~= -sx * 0.05;
      break;
    case 6:
      structure ~= createShaft(localRand, sx / 4, -sx / 2, so, sd1, sl * 0.6, 1, sw * 0.6, sd1 / 3, sd2 / 2, cl, shp, 5, 1);
      structure ~= createShaft(localRand, sx / 4, -sx / 2, so, sd1, sl * 0.6, 1, sw * 0.6, sd1 / 3, sd2 / 2, cl, shp, 5, -1);
      structure ~= createShaft(localRand, sx / 2, -sx / 3 * 2, so, sd1, sl * 0.8, 1, sw * 0.8, sd1 / 3, sd2 / 3 * 2, cl, shp, 5, 1);
      structure ~= createShaft(localRand, sx / 2, -sx / 3 * 2, so, sd1, sl * 0.8, 1, sw * 0.8, sd1 / 3, sd2 / 3 * 2, cl, shp, 5, -1);
      structure ~= createShaft(localRand, sx, 0, so, sd1, sl, 1, sw, sd1 / 2, sd2, cl, shp, 5, 1, damaged);
      structure ~= createShaft(localRand, sx, 0, so, sd1, sl, 1, sw, sd1 / 2, sd2, cl, shp, 5, -1, damaged);
      _collision.x = sx + so / 2 + sw;
      _collision.y = sl / 2;
      rocketX ~= sx * 0.0125;
      rocketX ~= -sx * 0.0125;
      rocketX ~= sx * 0.025;
      rocketX ~= -sx * 0.025;
      rocketX ~= sx * 0.05;
      rocketX ~= -sx * 0.05;
      break;
    default: break;
    }
    _collision.x *= 0.1;
    _collision.y *= 1.2;
  }

  private Structure[] createShaft(Rand localRand, float ox, float oy, float offset,
                                  float od1, float rocketLength,
                                  int wingNum, float wingWidth,
                                  float wingD1, float wingD2, int color, int shp, int divNum,
                                  int rev, bool damaged = false) {
    Structure[] sts;
    Structure st = new Structure;
    st.pos.x = ox;
    st.pos.y = oy;
    st.d1 = st.d2 = 0;
    st.width = rocketLength * 0.15;
    st.height = rocketLength;
    st.shape = Structure.Shape.ROCKET;
    st.shapeXReverse = 1;
    if (!damaged)
      st.color = 1;
    else
      st.color = 0;
    if (rev == -1)
      st.pos.x *= -1;
    sts ~= st;
    float wofs = offset;
    float whgt = rocketLength * (localRand.nextFloat(0.5) + 1.5);
    for (int i = 0; i < wingNum; i++) {
      st = new Structure;
      st.d1 = wingD1 * 180 / PI;
      st.d2 = wingD2 * 180 / PI;
      st.pos.x = ox + sin(od1) * wofs;
      st.pos.y = oy + cos(od1) * wofs;
      st.width = wingWidth;
      st.height = whgt;
      st.shape = cast(Structure.Shape)shp;
      st.divNum = divNum;
      st.shapeXReverse = 1;
      if (!damaged)
        st.color = color;
      else
        st.color = 0;
      if ((((i % 2) * 2) - 1) * rev == 1) {
        st.pos.x *= -1;
        st.d1 *= -1;
        st.shapeXReverse *= -1;
      }
      sts ~= st;
    }
    return sts;
  }

  // Add particles from rockets.
  public void addParticles(Vector pos, ParticlePool particles) {
    foreach (float rx; rocketX) {
      Particle pt = particles.getInstance();
      if (!pt)
        break;
      rocketPos.x = pos.x + rx;
      rocketPos.y = pos.y - 0.15;
      pt.set(rocketPos, 1, PI, 0, 0.2, 0.3, 0.4, 1.0, 16, Particle.PType.JET);
    }
  }

  // Add fragments when an enemy is destoyed.
  public void addFragments(Vector pos, ParticlePool particles) {
    if (collision.x < 0.5)
      return;
    for (int i = 0; i < collision.x * 40; i++) {
      Particle pt = particles.getInstance();
      if (!pt)
        break;
      fragmentPos.x = pos.x;
      fragmentPos.y = pos.y;
      float wb = collision.x;
      float hb = collision.y;
      pt.set(fragmentPos, 1, rand.nextSignedFloat(0.1),
             1 + rand.nextSignedFloat(1), 0.2 + rand.nextFloat(0.2),
             Structure.COLOR_RGB[color][0],
             Structure.COLOR_RGB[color][1],
             Structure.COLOR_RGB[color][2],
             32 + rand.nextInt(16), Particle.PType.FRAGMENT,
             wb + rand.nextFloat(wb), hb + rand.nextFloat(hb));
    }
  }

  public void draw() {
    foreach (Structure st; structure) {
      st.createDisplayList();
    }
  }

  public Vector collision() {
    return _collision;
  }
}

/**
 * Structures that make up ShipShape.
 */
public class Structure {
 public:
  static const float[3][] COLOR_RGB = [
    [1, 1, 1],
    [0.6, 0.6, 0.6],
    [0.9, 0.5, 0.5],
    [0.5, 0.9, 0.5],
    [0.5, 0.5, 0.9],
    [0.7, 0.7, 0.5],
    [0.7, 0.5, 0.7],
    [0.5, 0.7, 0.7],
  ];
  Vector pos;
  float d1, d2;
  static enum Shape {
    SQUARE, WING, TRIANGLE, ROCKET,
  };
  float width, height;
  Shape shape;
  float shapeXReverse;
  int color;
  int divNum;
 private:

  public this() {
    pos = new Vector;
  }

  public void createDisplayList() {
    GL.pushMatrix();
    GL.translate(pos.x, pos.y, 0);
    GL.rotate(-d2, 1, 0, 0);
    GL.rotate(d1, 0, 0, 1);
    if (shape == Shape.ROCKET)
      GL.scale(width, width, height);
    else
      GL.scale(width, height, 1);
    GL.scale(shapeXReverse, 1, 1);
    float alp = 0.5;
    if (color == 0)
      alp = 1;
    Screen.setColor(COLOR_RGB[color][0], COLOR_RGB[color][1], COLOR_RGB[color][2]);
    final switch (shape) {
    case Shape.SQUARE:
      for (int i = 0; i < divNum; i++) {
        float x11 = -0.5 + (1.0 / divNum) * i;
        float x12 = x11 + (1.0 / divNum) * 0.8;
        float x21 = -0.5 + (0.8 / divNum) * i;
        float x22 = x21 + (0.8 / divNum) * 0.8;
        GL.begin(GL.LINE_LOOP);
        GL.vertex(x21, 0, -0.5);
        GL.vertex(x22, 0, -0.5);
        GL.vertex(x12, 0, 0.5);
        GL.vertex(x11, 0, 0.5);
        GL.end();
        GL.begin(GL.LINE_LOOP);
        GL.vertex(x21, 0.1, -0.5);
        GL.vertex(x22, 0.1, -0.5);
        GL.vertex(x12, 0.1, 0.5);
        GL.vertex(x11, 0.1, 0.5);
        GL.end();
        Screen.setColor(COLOR_RGB[color][0], COLOR_RGB[color][1], COLOR_RGB[color][2], alp);
        GL.begin(GL.TRIANGLE_FAN);
        GL.vertex(x21, 0, -0.5);
        GL.vertex(x22, 0, -0.5);
        GL.vertex(x12, 0, 0.5);
        GL.vertex(x11, 0, 0.5);
        GL.end();
      }
      break;
    case Shape.WING:
      for (int i = 0; i < divNum; i++) {
        float x1 = -0.5 + (1.0 / divNum) * i;
        float x2 = x1 + (1.0 / divNum) * 0.8;
        float y1 = x1;
        float y2 = x2;
        GL.begin(GL.LINE_LOOP);
        GL.vertex(x1, 0, y1);
        GL.vertex(x2, 0, y2);
        GL.vertex(x2, 0, 0.5);
        GL.vertex(x1, 0, 0.5);
        GL.end();
        GL.begin(GL.LINE_LOOP);
        GL.vertex(x1, 0.1, y1);
        GL.vertex(x2, 0.1, y2);
        GL.vertex(x2, 0.1, 0.5);
        GL.vertex(x1, 0.1, 0.5);
        GL.end();
        Screen.setColor(COLOR_RGB[color][0], COLOR_RGB[color][1], COLOR_RGB[color][2], alp);
        GL.begin(GL.TRIANGLE_FAN);
        GL.vertex(x1, 0, y1);
        GL.vertex(x2, 0, y2);
        GL.vertex(x2, 0, 0.5);
        GL.vertex(x1, 0, 0.5);
        GL.end();
      }
      break;
    case Shape.TRIANGLE:
      for (int i = 0; i < divNum; i++) {
        float x1 = -0.5 + (1.0 / divNum) * i;
        float x2 = x1 + (1.0 / divNum) * 0.8;
        float y1 = -0.5 + (1.0 / divNum) * fabs(cast(float)i - divNum / 2) * 2;
        float y2 = -0.5 + (1.0 / divNum) * fabs(cast(float)i + 0.8 - divNum / 2) * 2;
        GL.begin(GL.LINE_LOOP);
        GL.vertex(x1, 0, y1);
        GL.vertex(x2, 0, y2);
        GL.vertex(x2, 0, 0.5);
        GL.vertex(x1, 0, 0.5);
        GL.end();
        GL.begin(GL.LINE_LOOP);
        GL.vertex(x1, 0.1, y1);
        GL.vertex(x2, 0.1, y2);
        GL.vertex(x2, 0.1, 0.5);
        GL.vertex(x1, 0.1, 0.5);
        GL.end();
        Screen.setColor(COLOR_RGB[color][0], COLOR_RGB[color][1], COLOR_RGB[color][2], alp);
        GL.begin(GL.TRIANGLE_FAN);
        GL.vertex(x1, 0, y1);
        GL.vertex(x2, 0, y2);
        GL.vertex(x2, 0, 0.5);
        GL.vertex(x1, 0, 0.5);
        GL.end();
      }
      break;
    case Shape.ROCKET:
      for (int i = 0; i < 4; i++) {
        float d = i * PI / 2 + PI / 4;
        GL.begin(GL.LINE_LOOP);
        GL.vertex(sin(d - 0.3), cos(d - 0.3), -0.5);
        GL.vertex(sin(d + 0.3), cos(d + 0.3), -0.5);
        GL.vertex(sin(d + 0.3), cos(d + 0.3), 0.5);
        GL.vertex(sin(d - 0.3), cos(d - 0.3), 0.5);
        GL.end();
        Screen.setColor(COLOR_RGB[color][0], COLOR_RGB[color][1], COLOR_RGB[color][2], alp);
        GL.begin(GL.TRIANGLE_FAN);
        GL.vertex(sin(d - 0.3), cos(d - 0.3), -0.5);
        GL.vertex(sin(d + 0.3), cos(d + 0.3), -0.5);
        GL.vertex(sin(d + 0.3), cos(d + 0.3), 0.5);
        GL.vertex(sin(d - 0.3), cos(d - 0.3), 0.5);
        GL.end();
      }
      break;
    }
    GL.popMatrix();
  }
}

/**
 * Shape for an enemy's bit.
 */
public class BitShape: Drawable {
 private:
  static const float[] COLOR_RGB = [1, 0.9, 0.5];

  public void draw() {
    for (int i = 0; i < 4; i++) {
      float d = i * PI / 2 + PI / 4;
      Screen.setColor(COLOR_RGB[0], COLOR_RGB[1], COLOR_RGB[2]);
      GL.begin(GL.LINE_LOOP);
      GL.vertex(sin(d - 0.3), -0.8, cos(d - 0.3));
      GL.vertex(sin(d + 0.3), -0.8, cos(d + 0.3));
      GL.vertex(sin(d + 0.3), 0.8, cos(d + 0.3));
      GL.vertex(sin(d - 0.3), 0.8, cos(d - 0.3));
      GL.end();
      d += PI / 4;
      GL.begin(GL.LINE_LOOP);
      GL.vertex(sin(d - 0.3) * 2, -0.2, cos(d - 0.3) * 2);
      GL.vertex(sin(d + 0.3) * 2, -0.2, cos(d + 0.3) * 2);
      GL.vertex(sin(d + 0.3) * 2, 0.2, cos(d + 0.3) * 2);
      GL.vertex(sin(d - 0.3) * 2, 0.2, cos(d - 0.3) * 2);
      GL.end();
      d -= PI / 4;
      Screen.setColor(COLOR_RGB[0], COLOR_RGB[1], COLOR_RGB[2], 0.5);
      GL.begin(GL.TRIANGLE_FAN);
      GL.vertex(sin(d - 0.3), -0.8, cos(d - 0.3));
      GL.vertex(sin(d + 0.3), -0.8, cos(d + 0.3));
      GL.vertex(sin(d + 0.3), 0.8, cos(d + 0.3));
      GL.vertex(sin(d - 0.3), 0.8, cos(d - 0.3));
      GL.end();
      d += PI / 4;
      GL.begin(GL.TRIANGLE_FAN);
      GL.vertex(sin(d - 0.3) * 2, -0.2, cos(d - 0.3) * 2);
      GL.vertex(sin(d + 0.3) * 2, -0.2, cos(d + 0.3) * 2);
      GL.vertex(sin(d + 0.3) * 2, 0.2, cos(d + 0.3) * 2);
      GL.vertex(sin(d - 0.3) * 2, 0.2, cos(d - 0.3) * 2);
      GL.end();
    }
  }
}

/**
 * Shape for an enemy's bullet.
 */
public class BulletShape: Drawable {
 public:
  static enum BSType {
    TRIANGLE, TRIANGLE_WIRE,
    SQUARE, SQUARE_WIRE,
    BAR, BAR_WIRE,
  };
  static const int NUM = 6;
 private:
  static const float[] COLOR_RGB = [1, 0.7, 0.8];
  BSType shapeType;

  public void create(BSType type) {
    shapeType = type;
  }

  public void draw() {
    final switch (shapeType) {
    case BSType.TRIANGLE:
      createTriangleShape(false);
      break;
    case BSType.TRIANGLE_WIRE:
      createTriangleShape(true);
      break;
    case BSType.SQUARE:
      createSquareShape(false);
      break;
    case BSType.SQUARE_WIRE:
      createSquareShape(true);
      break;
    case BSType.BAR:
      createBarShape(false);
      break;
    case BSType.BAR_WIRE:
      createBarShape(true);
      break;
    }
  }

  private void createTriangleShape(bool wireShape) {
    scope auto cp = new Vector3;
    scope auto p1 = new Vector3;
    scope auto p2 = new Vector3;
    scope auto p3 = new Vector3;
    scope auto np1 = new Vector3;
    scope auto np2 = new Vector3;
    scope auto np3 = new Vector3;
    for (int i = 0; i < 3; i++) {
      float d = PI * 2 / 3 * i;
      p1.x = p1.y = 0;
      p1.z = 2.5f;
      p2.x = sin(d) * 1.8f;
      p2.y = cos(d) * 1.8f;
      p2.z = -1.2f;
      p3.x = sin(d + PI * 2 / 3) * 1.2f;
      p3.y = cos(d + PI * 2 / 3) * 1.2f;
      p3.z = -1.2f;
      cp.x = cp.y = cp.z = 0;
      cp += p1;
      cp += p2;
      cp += p3;
      cp /= 3;
      np1.blend(p1, cp, 0.6);
      np2.blend(p2, cp, 0.6);
      np3.blend(p3, cp, 0.6);
      if (!wireShape)
        Screen.setColor(COLOR_RGB[0], COLOR_RGB[1], COLOR_RGB[2]);
      else
        Screen.setColor(COLOR_RGB[0] * 0.6, COLOR_RGB[1], COLOR_RGB[2]);
      GL.begin(GL.LINE_LOOP);
      GL.vertex(np1);
      GL.vertex(np2);
      GL.vertex(np3);
      GL.end();
      if (!wireShape) {
        GL.begin(GL.TRIANGLE_FAN);
        Screen.setColor(COLOR_RGB[0] * 0.7, COLOR_RGB[1] * 0.7, COLOR_RGB[2] * 0.7);
        GL.vertex(np1);
        Screen.setColor(COLOR_RGB[0] * 0.4, COLOR_RGB[1] * 0.4, COLOR_RGB[2] * 0.4);
        GL.vertex(np2);
        GL.vertex(np3);
        GL.end();
      }
    }
  }

  private void createSquareShape(bool wireShape) {
    scope auto cp = new Vector3;
    scope auto p0 = new Vector3;
    scope auto p1 = new Vector3;
    scope auto p2 = new Vector3;
    scope auto p3 = new Vector3;
    scope auto np0 = new Vector3;
    scope auto np1 = new Vector3;
    scope auto np2 = new Vector3;
    scope auto np3 = new Vector3;
    static const float[][][] POINT_DAT = [
      [[-1, -1, 1], [1, -1, 1], [1, 1, 1], [-1, 1, 1], ],
      [[-1, -1, -1], [1, -1, -1], [1, 1, -1], [-1, 1, -1], ],
      [[-1, 1, -1], [1, 1, -1], [1, 1, 1], [-1, 1, 1], ],
      [[-1, -1, -1], [1, -1, -1], [1, -1, 1], [-1, -1, 1], ],
      [[1, -1, -1], [1, -1, 1], [1, 1, 1], [1, 1, -1], ],
      [[-1, -1, -1], [-1, -1, 1], [-1, 1, 1], [-1, 1, -1], ],
    ];
    for (int i = 0; i < 6; i++) {
      cp.x = cp.y = cp.z = 0;
      p0.x = POINT_DAT[i][0][0];
      p0.y = POINT_DAT[i][0][1];
      p0.z = POINT_DAT[i][0][2];
      cp += p0;
      p1.x = POINT_DAT[i][1][0];
      p1.y = POINT_DAT[i][1][1];
      p1.z = POINT_DAT[i][1][2];
      cp += p1;
      p2.x = POINT_DAT[i][2][0];
      p2.y = POINT_DAT[i][2][1];
      p2.z = POINT_DAT[i][2][2];
      cp += p2;
      p3.x = POINT_DAT[i][3][0];
      p3.y = POINT_DAT[i][3][1];
      p3.z = POINT_DAT[i][3][2];
      cp += p3;
      cp /= 4;
      np0.blend(p0, cp, 0.6);
      np1.blend(p1, cp, 0.6);
      np2.blend(p2, cp, 0.6);
      np3.blend(p3, cp, 0.6);
      if (!wireShape)
        Screen.setColor(COLOR_RGB[0], COLOR_RGB[1], COLOR_RGB[2]);
      else
        Screen.setColor(COLOR_RGB[0] * 0.6, COLOR_RGB[1], COLOR_RGB[2]);
      GL.begin(GL.LINE_LOOP);
      GL.vertex(np0);
      GL.vertex(np1);
      GL.vertex(np2);
      GL.vertex(np3);
      GL.end();
      if (!wireShape) {
        GL.begin(GL.TRIANGLE_FAN);
        Screen.setColor(COLOR_RGB[0] * 0.7, COLOR_RGB[1] * 0.7, COLOR_RGB[2] * 0.7);
        GL.vertex(np0);
        GL.vertex(np1);
        GL.vertex(np2);
        GL.vertex(np3);
        GL.end();
      }
    }
  }

  private void createBarShape(bool wireShape) {
    scope auto cp = new Vector3;
    scope auto p0 = new Vector3;
    scope auto p1 = new Vector3;
    scope auto p2 = new Vector3;
    scope auto p3 = new Vector3;
    scope auto np0 = new Vector3;
    scope auto np1 = new Vector3;
    scope auto np2 = new Vector3;
    scope auto np3 = new Vector3;
    static const float[][][] POINT_DAT = [
      [[-1, -1, 1], [1, -1, 1], [1, 1, 1], [-1, 1, 1], ],
      //[[-1, -1, -1], [1, -1, -1], [1, 1, -1], [-1, 1, -1], ],
      [[-1, 1, -1], [1, 1, -1], [1, 1, 1], [-1, 1, 1], ],
      [[-1, -1, -1], [1, -1, -1], [1, -1, 1], [-1, -1, 1], ],
      [[1, -1, -1], [1, -1, 1], [1, 1, 1], [1, 1, -1], ],
      [[-1, -1, -1], [-1, -1, 1], [-1, 1, 1], [-1, 1, -1], ],
    ];
    for (int i = 0; i < 5; i++) {
      cp.x = cp.y = cp.z = 0;
      p0.x = POINT_DAT[i][0][0] * 0.7f;
      p0.y = POINT_DAT[i][0][1] * 0.7f;
      p0.z = POINT_DAT[i][0][2] * 1.75f;
      cp += p0;
      p1.x = POINT_DAT[i][1][0] * 0.7f;
      p1.y = POINT_DAT[i][1][1] * 0.7f;
      p1.z = POINT_DAT[i][1][2] * 1.75f;
      cp += p1;
      p2.x = POINT_DAT[i][2][0] * 0.7f;
      p2.y = POINT_DAT[i][2][1] * 0.7f;
      p2.z = POINT_DAT[i][2][2] * 1.75f;
      cp += p2;
      p3.x = POINT_DAT[i][3][0] * 0.7f;
      p3.y = POINT_DAT[i][3][1] * 0.7f;
      p3.z = POINT_DAT[i][3][2] * 1.75f;
      cp += p3;
      cp /= 4;
      np0.blend(p0, cp, 0.6);
      np1.blend(p1, cp, 0.6);
      np2.blend(p2, cp, 0.6);
      np3.blend(p3, cp, 0.6);
      if (!wireShape)
        Screen.setColor(COLOR_RGB[0], COLOR_RGB[1], COLOR_RGB[2]);
      else
        Screen.setColor(COLOR_RGB[0] * 0.6, COLOR_RGB[1], COLOR_RGB[2]);
      GL.begin(GL.LINE_LOOP);
      GL.vertex(np0);
      GL.vertex(np1);
      GL.vertex(np2);
      GL.vertex(np3);
      GL.end();
      if (!wireShape) {
        GL.begin(GL.TRIANGLE_FAN);
        Screen.setColor(COLOR_RGB[0] * 0.7, COLOR_RGB[1] * 0.7, COLOR_RGB[2] * 0.7);
        GL.vertex(np0);
        GL.vertex(np1);
        GL.vertex(np2);
        GL.vertex(np3);
        GL.end();
      }
    }
  }
}

/**
 * Shape for a player's shot.
 */
public class ShotShape: Collidable, Drawable {
  mixin CollidableImpl;
 private:
  static const float[] COLOR_RGB = [0.8, 1, 0.7];
  bool _charge;
  Vector _collision = new Vector();

  public void create(bool charge) {
    _charge = charge;
  }

  public void draw() {
    if (_charge) {
      for (int i = 0; i < 8; i++) {
        float d = i * PI / 4;
        GL.begin(GL.TRIANGLES);
        Screen.setColor(COLOR_RGB[0], COLOR_RGB[1], COLOR_RGB[2]);
        GL.vertex(sin(d) * 0.1, cos(d) * 0.1, 0.2);
        GL.vertex(sin(d) * 0.5, cos(d) * 0.5, 0.5);
        Screen.setColor(COLOR_RGB[0] * 0.2, COLOR_RGB[1] * 0.2, COLOR_RGB[2] * 0.2);
        GL.vertex(sin(d) * 1.0, cos(d) * 1.0, -0.7);
        GL.end();
        Screen.setColor(COLOR_RGB[0], COLOR_RGB[1], COLOR_RGB[2]);
        GL.begin(GL.LINE_LOOP);
        GL.vertex(sin(d) * 0.1, cos(d) * 0.1, 0.2);
        GL.vertex(sin(d) * 0.5, cos(d) * 0.5, 0.5);
        GL.vertex(sin(d) * 1.0, cos(d) * 1.0, -0.7);
        GL.end();
      }
    } else {
      for (int i = 0; i < 4; i++) {
        float d = i * PI / 2;
        GL.begin(GL.TRIANGLES);
        Screen.setColor(COLOR_RGB[0], COLOR_RGB[1], COLOR_RGB[2]);
        GL.vertex(sin(d) * 0.1, cos(d) * 0.1, 0.4);
        GL.vertex(sin(d) * 0.3, cos(d) * 0.3, 1.0);
        Screen.setColor(COLOR_RGB[0] * 0.2, COLOR_RGB[1] * 0.2, COLOR_RGB[2] * 0.2);
        GL.vertex(sin(d) * 0.5, cos(d) * 0.5, -1.4);
        GL.end();
        Screen.setColor(COLOR_RGB[0], COLOR_RGB[1], COLOR_RGB[2]);
        GL.begin(GL.LINE_LOOP);
        GL.vertex(sin(d) * 0.1, cos(d) * 0.1, 0.4);
        GL.vertex(sin(d) * 0.3, cos(d) * 0.3, 1.0);
        GL.vertex(sin(d) * 0.5, cos(d) * 0.5, -1.4);
        GL.end();
      }
    }
    _collision.x = 0.15;
    _collision.y = 0.3;
  }

  public Vector collision() {
    return _collision;
  }
}

/**
 * Drawable that can change it's size.
 */
public class ResizableDrawable: Collidable, Drawable {
  mixin CollidableImpl;
 private:
  Drawable _shape;
  float _size;
  Vector _collision;

  public void draw() {
    GL.scale(_size, _size, _size);
    _shape.draw();
  }

  public Drawable shape(Drawable v) {
    _collision = new Vector;
    return _shape = v;
  }
  
  public float size(float v) {
    return _size = v;
  }

  public Vector collision() {
    Collidable cd = cast(Collidable) _shape;
    if (cd) {
      _collision.x = cd.collision.x * _size;
      _collision.y = cd.collision.y * _size;
      return _collision;
    } else {
      return null;
    }
  }
}
