import com.hamoid.*;
import java.util.Random;
import java.util.ArrayList;

VideoExport videoExport;
String VIDEO_FILE_NAME = "ievan.mp4";

float SCALE = 1; // 1080p. If you change this, you also have to go to size(1920,1080); down below, and change that too.
float PLAY_SPEED = 1;
float FPS = 60;

double BPM = 121;
int currentBeat = 0;

// PImage bg;
PFont font;
float time = 0;
int frames = 0;

Random rng = new Random(123);

void setup(){
  // bg = loadImage("bg.png");
  font = createFont("arial.ttf", 96);
  size(1920,1080);
  frameRate(FPS);
  noStroke();
  fill(0);
  rectMode(CENTER);
  
  videoExport = new VideoExport(this, VIDEO_FILE_NAME);
  videoExport.setFrameRate(FPS);
  videoExport.startMovie();
}

void drawVDJ(VDJ vdj, int xOffset) {
  if (vdj == null) {
    return;
  }
  fill(255);
  final int Y_CENTER = 400;
  rect(xOffset, Y_CENTER, 400, 150);
  fill(0);
  text("V" + vdj.V, xOffset - 175.0/2, Y_CENTER - 50);
  text("D" + vdj.D, xOffset + 175.0/4, Y_CENTER - 50);
  text("J" + vdj.J, xOffset + 175.0*3/4, Y_CENTER - 50);
  String KaText = "Ka = " + (Double.toString(vdj.KaCoefficient)).substring(0, 4) + " * 10^" + vdj.KaExponent;
  text(KaText, xOffset, Y_CENTER + 50);
  
  final int HALF_DNA_HEIGHT = 10;
  final int DNA_LABEL_HEIGHT = 10;
  final float NUCLEOTIDE_WIDTH = 2;
  
  {
    final int Y_BASELINE = Y_CENTER - HALF_DNA_HEIGHT;
    final int DNA_LABEL_DIRECTION = - DNA_LABEL_HEIGHT;
    stroke(0);
    line(xOffset - 175, Y_BASELINE, xOffset - 175, Y_BASELINE - DNA_LABEL_HEIGHT+ DNA_LABEL_DIRECTION);
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
    final int Y_BASELINE = Y_CENTER;
    
    stroke(0);
    line(xOffset - 175, Y_BASELINE, xOffset + 175.0, Y_BASELINE);
    noStroke();
    
    rectMode(CORNERS);
    fill(240 - 3*vdj.V, 100 - 3*vdj.V, 100 - 3*vdj.V);
    rect(xOffset - 175, Y_BASELINE - HALF_DNA_HEIGHT, xOffset - 0 - NUCLEOTIDE_WIDTH * 1.5 - NUCLEOTIDE_WIDTH * vdj.VRightDel, Y_BASELINE + HALF_DNA_HEIGHT);
    fill(100 - 3*vdj.D, 240 - 3*vdj.D, 100 - 3*vdj.D);
    rect(xOffset - 0 + NUCLEOTIDE_WIDTH * 1.5 + NUCLEOTIDE_WIDTH * vdj.DLeftDel, Y_BASELINE - HALF_DNA_HEIGHT, xOffset + 175.0/2 - NUCLEOTIDE_WIDTH * 1.5 - NUCLEOTIDE_WIDTH * vdj.DRightDel, Y_BASELINE + HALF_DNA_HEIGHT);
    fill(100 - 3*vdj.J, 100 - 3*vdj.J, 240 - 3*vdj.J);
    rect(xOffset + 175.0/2 + NUCLEOTIDE_WIDTH * 1.5 + NUCLEOTIDE_WIDTH * vdj.JLeftDel, Y_BASELINE - HALF_DNA_HEIGHT, xOffset + 175.0, Y_BASELINE + HALF_DNA_HEIGHT);
    fill(128);
    rect(xOffset - 0 - NUCLEOTIDE_WIDTH * vdj.VDIns / 2.0, Y_BASELINE - HALF_DNA_HEIGHT, xOffset - 0 + NUCLEOTIDE_WIDTH * vdj.VDIns / 2.0, Y_BASELINE + HALF_DNA_HEIGHT);
    rect(xOffset + 175.0/2 - NUCLEOTIDE_WIDTH * vdj.DJIns / 2.0, Y_BASELINE - HALF_DNA_HEIGHT, xOffset + 175.0/2 + NUCLEOTIDE_WIDTH * vdj.DJIns / 2.0, Y_BASELINE + HALF_DNA_HEIGHT);
    rectMode(CENTER);
    fill(0);
  }
}

void updateStage() {
  if (time < 5 && currentStage != 0) {
    currentStage = 0;
    updateVDJ1 = true;
  } else if (time >= 5 && time < 10 && currentStage != 1) {
    currentStage = 1;
    updateVDJ1 = true;
  } else if (time > 10 && currentStage != 2) {
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
      vdj1 = new VDJ(lbound, ubound);
      break;
    case 1:
      lbound = 6;
      ubound = 8;
      if (updateVDJ1) {
        // only do this once
        vdj1 = new VDJ(lbound, ubound);
        updateVDJ1 = false;
      }
      break;
    case 2:
      lbound = -5;
      ubound = vdj2.KaExponent + 2;
      vdj1.mutate(lbound, ubound);
  }
  if (vdj2 == null || vdj2.KaExponent < vdj1.KaExponent || (vdj2.KaExponent == vdj1.KaExponent && vdj2.KaCoefficient < vdj1.KaCoefficient)) {
    vdj2 = new VDJ(vdj1);
  }
}

boolean updateVDJ1 = true;
int currentStage;
VDJ vdj1;
VDJ vdj2;

void draw(){
  background(0, 255, 0);
  int expectedBeat = (int) (time * BPM / (double) 60) + 1; // start at 1
  updateStage();
  updateVDJ(expectedBeat);
  drawVDJ(vdj1, 420);
  drawVDJ(vdj2, 840);
  scale(SCALE);
  // lights();
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
  }
  
  VDJ(int minKaExp, int maxKaExp) {
    // numbers for deletion and insertion and Ka are arbitratily chosen
    V = rng.nextInt(44) + 1;
    VRightDel = rng.nextInt(6);
    VDIns = rng.nextInt(2);
    for (int i = 0; i < VDIns; i++) {
      VDInsMutations += randomBase();
    }
    DLeftDel = rng.nextInt(6);
    D = rng.nextInt(27) + 1;
    DRightDel = rng.nextInt(6);
    DJIns = rng.nextInt(2);
    for (int i = 0; i < DJIns; i++) {
      DJInsMutations += randomBase();
    }
    JLeftDel = rng.nextInt(6);
    J = rng.nextInt(6) + 1;
    newKa(minKaExp, maxKaExp);
    mutationLoci = new ArrayList<Double>();
    mutations = new ArrayList<String>();
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
