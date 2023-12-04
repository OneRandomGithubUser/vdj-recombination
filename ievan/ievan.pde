import com.hamoid.*;
import java.util.Random;
import java.util.ArrayList;

VideoExport videoExport;
String VIDEO_FILE_NAME = "ievan.mp4";

float SCALE = 1; // 1080p. If you change this, you also have to go to size(1920,1080); down below, and change that too.
float PLAY_SPEED = 1;
float FPS = 60;

double BPM = 121 * 2;
int currentBeat = 0;

// PImage bg;
PFont arial;
float time = 0;
int frames = 0;

Random rng = new Random(6);

void setup(){
  // bg = loadImage("bg.png");
  arial = createFont("arial.ttf", 12);
  textFont(arial);
  size(3840,2160);
  frameRate(FPS);
  noStroke();
  fill(0);
  rectMode(CENTER);
  textAlign(CENTER, CENTER);
  
  videoExport = new VideoExport(this, VIDEO_FILE_NAME);
  videoExport.setFrameRate(FPS);
  videoExport.startMovie();
}

String exponentize(int num) {
  String ans = "";
  String temp = "";
  String[] superscript = {"⁰","¹","²","³","⁴","⁵","⁶","⁷","⁸","⁹"};
  if (num < 0) {
    ans += "‾"; // ⁻ not supported by this copy of Arial
  }
  int tens = Math.abs(num);
  do {
    temp = superscript[tens%10] + temp;
    tens = (int) Math.floor(tens/10);
  } while (tens != 0);
  ans += temp;
  return ans;
}

void drawVDJ(VDJ vdjHeavy, VDJ vdjLight, int xOffset) {
  if (vdjHeavy == null) {
    return;
  }
  
  rectMode(CORNERS);
  fill(255);
  final int Y_CENTER = 400;
  rect(xOffset - 200, Y_CENTER - 75, xOffset + 200, Y_CENTER + 150);
  fill(0);
  rectMode(CENTER);
  
  textSize(30);
  text("V" + vdjHeavy.V, xOffset - 175.0/2, Y_CENTER - 60);
  text("D" + vdjHeavy.D, xOffset + 175.0/4, Y_CENTER - 60);
  text("J" + vdjHeavy.J, xOffset + 175.0*3/4, Y_CENTER - 60);
  text("V" + vdjLight.V, xOffset - 175.0/2, Y_CENTER + 60);
  text("J" + vdjLight.J, xOffset + 175.0/4, Y_CENTER + 60);
  textSize(12);
  
  String KaText;
  String KaValue;
  if (vdjHeavy.hasValidReadingFrame) {
    KaText = "Binding Affinity:";
    KaValue = "Kₐ = " + (Double.toString(vdjHeavy.KaCoefficient)).substring(0, 4) + " × 10" + exponentize(vdjHeavy.KaExponent);
  } else {
    KaText = "Binding Affinity: (invalid reading frame)";
    KaValue = "Kₐ = 0";
    fill(255, 31, 31);
  }
  textSize(20);
  text(KaText, xOffset, Y_CENTER + 87.5);
  textSize(40);
  text(KaValue, xOffset, Y_CENTER + 125);
  textSize(12);
  fill(0);
  
  final int HALF_DNA_HEIGHT = 10;
  final int DNA_LABEL_HEIGHT = 10;
  final float NUCLEOTIDE_WIDTH = 2;
  final float MAX_VDJ_COLOR_SHIFT = 100;
  
  {
    final float Y_BASELINE = Y_CENTER - HALF_DNA_HEIGHT * 3;
    final float DNA_LABEL_DIRECTION = - DNA_LABEL_HEIGHT;
    stroke(0);
    
    line(xOffset - 175, Y_BASELINE, xOffset - 175, Y_BASELINE + DNA_LABEL_DIRECTION);
    line(xOffset - 175, Y_BASELINE + DNA_LABEL_DIRECTION, xOffset - 0 - NUCLEOTIDE_WIDTH * 1.5, Y_BASELINE + DNA_LABEL_DIRECTION);
    line(xOffset - 0 - NUCLEOTIDE_WIDTH * 1.5, Y_BASELINE + DNA_LABEL_DIRECTION, xOffset - 0 - NUCLEOTIDE_WIDTH * 1.5, Y_BASELINE);
    
    line(xOffset - 0 + NUCLEOTIDE_WIDTH * 1.5, Y_BASELINE + DNA_LABEL_DIRECTION, xOffset - 0 + NUCLEOTIDE_WIDTH * 1.5, Y_BASELINE);
    line(xOffset - 0 + NUCLEOTIDE_WIDTH * 1.5, Y_BASELINE + DNA_LABEL_DIRECTION, xOffset + 175.0/2 - NUCLEOTIDE_WIDTH * 1.5, Y_BASELINE + DNA_LABEL_DIRECTION);
    line(xOffset + 175.0/2 - NUCLEOTIDE_WIDTH * 1.5, Y_BASELINE + DNA_LABEL_DIRECTION, xOffset + 175.0/2 - NUCLEOTIDE_WIDTH * 1.5, Y_BASELINE);
    
    line(xOffset + 175.0/2 + NUCLEOTIDE_WIDTH * 1.5, Y_BASELINE, xOffset + 175.0/2 + NUCLEOTIDE_WIDTH * 1.5, Y_BASELINE + DNA_LABEL_DIRECTION);
    line(xOffset + 175.0/2 + NUCLEOTIDE_WIDTH * 1.5, Y_BASELINE + DNA_LABEL_DIRECTION, xOffset + 175.0, Y_BASELINE + DNA_LABEL_DIRECTION);
    line(xOffset + 175.0, Y_BASELINE + DNA_LABEL_DIRECTION, xOffset + 175.0, Y_BASELINE);
    
    noStroke();
  }
  
  {
    final float Y_BASELINE = Y_CENTER - HALF_DNA_HEIGHT * 2;
    
    final float V_LEFT = xOffset - 175;
    final float V_RIGHT = xOffset - 0 - NUCLEOTIDE_WIDTH * 1.5 - NUCLEOTIDE_WIDTH * vdjHeavy.VRightDel;
    final float D_LEFT = xOffset - 0 + NUCLEOTIDE_WIDTH * 1.5 + NUCLEOTIDE_WIDTH * vdjHeavy.DLeftDel;
    final float D_RIGHT = xOffset + 175.0/2 - NUCLEOTIDE_WIDTH * 1.5 - NUCLEOTIDE_WIDTH * vdjHeavy.DRightDel;
    final float J_LEFT = xOffset + 175.0/2 + NUCLEOTIDE_WIDTH * 1.5 + NUCLEOTIDE_WIDTH * vdjHeavy.JLeftDel;
    final float J_RIGHT = xOffset + 175.0;
    
    text("IgH", xOffset - 187.5, Y_BASELINE);
    
    stroke(0);
    line(V_LEFT, Y_BASELINE, J_RIGHT, Y_BASELINE);
    noStroke();
    
    rectMode(CORNERS);
    final float V_COLOR_SHIFT = MAX_VDJ_COLOR_SHIFT*vdjHeavy.V/vdjHeavy.MAX_V;
    fill(240 - V_COLOR_SHIFT/2, 100 - V_COLOR_SHIFT, 100 - V_COLOR_SHIFT);
    rect(V_LEFT, Y_BASELINE - HALF_DNA_HEIGHT, V_RIGHT, Y_BASELINE + HALF_DNA_HEIGHT);
    final float D_COLOR_SHIFT = MAX_VDJ_COLOR_SHIFT*vdjHeavy.D/vdjHeavy.MAX_D;
    fill(100 - D_COLOR_SHIFT, 240 - D_COLOR_SHIFT/2, 100 - D_COLOR_SHIFT);
    rect(D_LEFT, Y_BASELINE - HALF_DNA_HEIGHT, D_RIGHT, Y_BASELINE + HALF_DNA_HEIGHT);
    final float J_COLOR_SHIFT = MAX_VDJ_COLOR_SHIFT*vdjHeavy.J/vdjHeavy.MAX_J;
    fill(100 - J_COLOR_SHIFT, 100 - J_COLOR_SHIFT, 240 - J_COLOR_SHIFT/2);
    rect(J_LEFT, Y_BASELINE - HALF_DNA_HEIGHT, J_RIGHT, Y_BASELINE + HALF_DNA_HEIGHT);
    fill(128);
    rect(xOffset - 0 - NUCLEOTIDE_WIDTH * vdjHeavy.VDIns / 2.0, Y_BASELINE - HALF_DNA_HEIGHT, xOffset - 0 + NUCLEOTIDE_WIDTH * vdjHeavy.VDIns / 2.0, Y_BASELINE + HALF_DNA_HEIGHT);
    rect(xOffset + 175.0/2 - NUCLEOTIDE_WIDTH * vdjHeavy.DJIns / 2.0, Y_BASELINE - HALF_DNA_HEIGHT, xOffset + 175.0/2 + NUCLEOTIDE_WIDTH * vdjHeavy.DJIns / 2.0, Y_BASELINE + HALF_DNA_HEIGHT);
    rectMode(CENTER);
    fill(0);
    
    rectMode(CORNERS);
    fill(0);
    for (double mutationLocus : vdjHeavy.mutationLoci) {
      double mutationXCoord = 0.0;
      if (mutationLocus < 1.0) {
        fill((240 - V_COLOR_SHIFT/2 + 128) % 255, (100 - V_COLOR_SHIFT + 128) % 255, (100 - V_COLOR_SHIFT + 128) % 255);
        mutationXCoord = (V_RIGHT - V_LEFT) * mutationLocus + V_LEFT;
      } else if (mutationLocus < 2.0) {
        fill((100 - D_COLOR_SHIFT/2 + 128) % 255, (240 - D_COLOR_SHIFT + 128) % 255, (100 - D_COLOR_SHIFT + 128) % 255);
        mutationXCoord = (D_RIGHT - D_LEFT) * (mutationLocus - 1.0) + D_LEFT;
      } else {
        fill((100 - J_COLOR_SHIFT/2 + 128) % 255, (100 - J_COLOR_SHIFT + 128) % 255, (240 - J_COLOR_SHIFT + 128) % 255);
        mutationXCoord = (J_RIGHT - J_LEFT) * (mutationLocus - 2.0) + J_LEFT;
      }
      rect((float) mutationXCoord - NUCLEOTIDE_WIDTH * 0.5, Y_BASELINE - HALF_DNA_HEIGHT, (float) mutationXCoord + NUCLEOTIDE_WIDTH * 0.5, Y_BASELINE + HALF_DNA_HEIGHT);
    }
    rectMode(CENTER);
    fill(0);
  }
  
  {
    final float Y_BASELINE = Y_CENTER + HALF_DNA_HEIGHT * 3;
    final float DNA_LABEL_DIRECTION = DNA_LABEL_HEIGHT;
    stroke(0);
    
    line(xOffset - 175, Y_BASELINE, xOffset - 175, Y_BASELINE + DNA_LABEL_DIRECTION);
    line(xOffset - 175, Y_BASELINE + DNA_LABEL_DIRECTION, xOffset - 0 - NUCLEOTIDE_WIDTH * 1.5, Y_BASELINE + DNA_LABEL_DIRECTION);
    line(xOffset - 0 - NUCLEOTIDE_WIDTH * 1.5, Y_BASELINE + DNA_LABEL_DIRECTION, xOffset - 0 - NUCLEOTIDE_WIDTH * 1.5, Y_BASELINE);
    
    line(xOffset - 0 + NUCLEOTIDE_WIDTH * 1.5, Y_BASELINE + DNA_LABEL_DIRECTION, xOffset - 0 + NUCLEOTIDE_WIDTH * 1.5, Y_BASELINE);
    line(xOffset - 0 + NUCLEOTIDE_WIDTH * 1.5, Y_BASELINE + DNA_LABEL_DIRECTION, xOffset + 175.0/2, Y_BASELINE + DNA_LABEL_DIRECTION);
    line(xOffset + 175.0/2, Y_BASELINE + DNA_LABEL_DIRECTION, xOffset + 175.0/2, Y_BASELINE);
    
    noStroke();
  }
  
  {
    final float Y_BASELINE = Y_CENTER + HALF_DNA_HEIGHT * 2;
    
    final float V_LEFT = xOffset - 175;
    final float V_RIGHT = xOffset - 0 - NUCLEOTIDE_WIDTH * 1.5 - NUCLEOTIDE_WIDTH * vdjLight.VRightDel;
    final float J_LEFT = xOffset - 0 + NUCLEOTIDE_WIDTH * 1.5 + NUCLEOTIDE_WIDTH * vdjLight.JLeftDel;
    final float J_RIGHT = xOffset + 175.0/2;
    
    text("IgL", xOffset - 187.5, Y_BASELINE);
    
    stroke(0);
    line(V_LEFT, Y_BASELINE, J_RIGHT, Y_BASELINE);
    noStroke();
    
    rectMode(CORNERS);
    final float V_COLOR_SHIFT = MAX_VDJ_COLOR_SHIFT*vdjLight.V/vdjLight.MAX_V;
    fill(240 - V_COLOR_SHIFT, 100 - V_COLOR_SHIFT, 100 - V_COLOR_SHIFT);
    rect(V_LEFT, Y_BASELINE - HALF_DNA_HEIGHT, V_RIGHT, Y_BASELINE + HALF_DNA_HEIGHT);
    final float J_COLOR_SHIFT = MAX_VDJ_COLOR_SHIFT*vdjLight.J/vdjLight.MAX_J;
    fill(100 - J_COLOR_SHIFT, 100 - J_COLOR_SHIFT, 240 - J_COLOR_SHIFT);
    rect(J_LEFT, Y_BASELINE - HALF_DNA_HEIGHT, J_RIGHT, Y_BASELINE + HALF_DNA_HEIGHT);
    fill(128);
    rect(xOffset - 0 - NUCLEOTIDE_WIDTH * vdjLight.VDIns / 2.0, Y_BASELINE - HALF_DNA_HEIGHT, xOffset - 0 + NUCLEOTIDE_WIDTH * vdjLight.VDIns / 2.0, Y_BASELINE + HALF_DNA_HEIGHT);
    rectMode(CENTER);
    fill(0);
    
    rectMode(CORNERS);
    fill(0);
    for (double mutationLocus : vdjLight.mutationLoci) {
      double mutationXCoord = 0.0;
      if (mutationLocus < 1.0) {
        fill((240 - V_COLOR_SHIFT + 128) % 255, (100 - V_COLOR_SHIFT + 128) % 255, (100 - V_COLOR_SHIFT + 128) % 255);
        mutationXCoord = (V_RIGHT - V_LEFT) * mutationLocus + V_LEFT;
      } else if (mutationLocus < 2.0) {
        continue;
      } else {
        fill((100 - J_COLOR_SHIFT + 128) % 255, (100 - J_COLOR_SHIFT + 128) % 255, (240 - J_COLOR_SHIFT + 128) % 255);
        mutationXCoord = (J_RIGHT - J_LEFT) * (mutationLocus - 2.0) + J_LEFT;
      }
      rect((float) mutationXCoord - NUCLEOTIDE_WIDTH * 0.5, Y_BASELINE - HALF_DNA_HEIGHT, (float) mutationXCoord + NUCLEOTIDE_WIDTH * 0.5, Y_BASELINE + HALF_DNA_HEIGHT);
    }
    rectMode(CENTER);
    fill(0);
  }
}

void updateStage() {
  if (time < 15 && currentStage != 0) {
    currentStage = 0;
    updateVDJ1 = true;
  } else if (time >= 15 && time < 20 && currentStage != 1) {
    currentStage = 1;
    updateVDJ1 = true;
  } else if (time > 20 && currentStage != 2) {
    currentStage = 2;
    updateVDJ1 = true;
  }
}

void updateVDJ(int expectedBeat) {
  if (expectedBeat == currentBeat) {
    return;
  }
  int lbound = 0;
  int ubound = 0;
  switch (currentStage) {
    case 0:
      lbound = -14;
      ubound = 6;
      vdj1Heavy = new VDJ(lbound, ubound);
      vdj1Light = new VDJ(lbound, ubound);
      break;
    case 1:
      lbound = 6;
      ubound = 8;
      if (updateVDJ1) {
        // only do this once
        do {
          vdj1Heavy = new VDJ(lbound, ubound);
        } while (!vdj1Heavy.hasValidReadingFrame);
        do {
          vdj1Light = new VDJ(lbound, ubound);
        } while (!vdj1Light.hasValidReadingFrame);
        updateVDJ1 = false;
      }
      break;
    case 2:
      lbound = -10;
      ubound = vdj2Heavy.KaExponent + 2;
      vdj1Heavy = new VDJ(vdj2Heavy);
      vdj1Light = new VDJ(vdj2Light);
      vdj1Heavy.mutate(lbound, ubound);
      vdj1Light.mutate(lbound, ubound);
  }
  if (vdj1Heavy.hasValidReadingFrame && (vdj2Heavy == null || vdj2Heavy.KaExponent < vdj1Heavy.KaExponent || (vdj2Heavy.KaExponent == vdj1Heavy.KaExponent && vdj2Heavy.KaCoefficient < vdj1Heavy.KaCoefficient))) {
    vdj2Heavy = new VDJ(vdj1Heavy);
    vdj2Light = new VDJ(vdj1Light);
  }
}

boolean updateVDJ1 = true;
int currentStage;
VDJ vdj1Heavy;
VDJ vdj1Light;
VDJ vdj2Heavy;
VDJ vdj2Light;

void draw(){
  scale(2.0);
  background(0, 255, 0);
  int expectedBeat = (int) (time * BPM / (double) 60) + 1; // start at 1
  updateStage();
  updateVDJ(expectedBeat);
  int vdj1XOffset;
  if (currentStage == 2) {
    vdj1XOffset = 400;
  } else {
    vdj1XOffset = 620;
  }
  if (currentStage != 1) {
    drawVDJ(vdj1Heavy, vdj1Light, vdj1XOffset);
  }
  drawVDJ(vdj2Heavy, vdj2Light, 1040);
  scale(SCALE);
  videoExport.saveFrame();
  time += PLAY_SPEED / (double) FPS;
  frames++;
  currentBeat = expectedBeat;
}

String randomBase() {
  int rand = rng.nextInt(4);
  switch (rand) {
    case 0:
      return "A";
    case 1:
      return "U";
    case 2:
      return "C";
    case 3:
      return "G";
    default:
      return "";
  }
}

public class VDJ {
  // package-private
  int V;
  int VRightDel;
  int VDIns;
  String VDInsMutations;
  int DLeftDel;
  int D;
  int DRightDel;
  int DJIns;
  String DJInsMutations;
  int JLeftDel;
  int J;
  double KaCoefficient;
  int KaExponent;
  ArrayList<Double> mutationLoci;
  ArrayList<String> mutations;
  boolean hasValidReadingFrame;
  
  final int MAX_V = 44;
  final int MAX_D = 27;
  final int MAX_J = 6;
  
  VDJ(VDJ other) {
    V = other.V;
    VRightDel = other.VRightDel;
    VDIns = other.VDIns;
    DLeftDel = other.DLeftDel;
    D = other.D;
    DRightDel = other.DRightDel;
    DJIns = other.DJIns;
    JLeftDel = other.JLeftDel;
    J = other.J;
    KaCoefficient = other.KaCoefficient;
    KaExponent = other.KaExponent;
    mutationLoci = new ArrayList<Double>(other.mutationLoci);
    mutations = new ArrayList<String>(other.mutations);
    hasValidReadingFrame = other.hasValidReadingFrame;
  }
  
  VDJ(int minKaExp, int maxKaExp) {
    // numbers for deletion and insertion and Ka are arbitratily chosen
    V = rng.nextInt(MAX_V) + 1;
    VRightDel = rng.nextInt(6);
    VDIns = rng.nextInt(3);
    for (int i = 0; i < VDIns; i++) {
      VDInsMutations += randomBase();
    }
    DLeftDel = rng.nextInt(6);
    D = rng.nextInt(MAX_D) + 1;
    DRightDel = rng.nextInt(6);
    DJIns = rng.nextInt(3);
    for (int i = 0; i < DJIns; i++) {
      DJInsMutations += randomBase();
    }
    JLeftDel = rng.nextInt(6);
    J = rng.nextInt(MAX_J) + 1;
    newKa(minKaExp, maxKaExp);
    mutationLoci = new ArrayList<Double>();
    mutations = new ArrayList<String>();
    hasValidReadingFrame = (VDIns + DJIns - (VRightDel + DLeftDel + DRightDel + JLeftDel)) % 3 == 0;
  }
  
  private void newKa(int minKaExp, int maxKaExp) {
    KaCoefficient = rng.nextDouble() * 9 + 1;
    // KaExponent is int in [minKaExp, maxKaExp)
    KaExponent = rng.nextInt(-minKaExp + maxKaExp) + minKaExp;
  }
  
  public void mutate(int minKaExp, int maxKaExp) {
    final int numMutations = rng.nextInt(2) + 1; // 1-3 mutations
    for (int i = 0; i < numMutations; i++) {
      double currLocation = rng.nextDouble();
      if (currLocation < 0.5) {
        currLocation *= 2; // [0, 0.5) to [0, 1)
      } else {
        currLocation = currLocation * 4 - 1; // [0.5, 1) to [1, 3)
      }
      mutationLoci.add(currLocation);
      mutations.add(randomBase());
    }
    newKa(minKaExp, maxKaExp);
  }
}
