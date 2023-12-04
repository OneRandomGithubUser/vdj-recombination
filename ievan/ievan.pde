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

Random rng = new Random();

void setup(){
  // bg = loadImage("bg.png");
  font = createFont("arial.ttf", 96);
  size(1920,1080);
  frameRate(FPS);
  fill(0);
  
  videoExport = new VideoExport(this, VIDEO_FILE_NAME);
  videoExport.setFrameRate(FPS);
  videoExport.startMovie();
}

void drawVDJ(VDJ vdj) {
  if (vdj == null) {
    return;
  }
  text("V" + vdj.V, 0, 40);
  text("D" + vdj.D, 0, 80);
  text("J" + vdj.J, 0, 120);
  text("Ka = " + (Double.toString(vdj.KaCoefficient)).substring(0, 4) + " * 10^" + vdj.KaExponent, 0, 160);
}

void updateStage() {
  if (time < 5) {
    currentStage = 0;
  } else if (time >= 5 && time < 10) {
    currentStage = 1;
  } else if (time > 10) {
    currentStage = 2;
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
      break;
    case 1:
      lbound = 6;
      ubound = 8;
      break;
    case 2:
      lbound = -10;
      ubound = 11;
  }
  vdj1 = new VDJ(lbound, ubound);
}

int currentStage;
VDJ vdj1;
VDJ vdj2;

void draw(){
  background(255);
  int expectedBeat = (int) (time * BPM / (double) 60) + 1; // start at 1
  updateStage();
  updateVDJ(expectedBeat);
  drawVDJ(vdj1);
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
  String VDIns;
  int DLeftDel;
  int D;
  int DRightDel;
  String DJIns;
  int JLeftDel;
  int J;
  double KaCoefficient;
  int KaExponent;
  ArrayList<Double> mutationLoci;
  ArrayList<String> mutations;
  VDJ(int minKaExp, int maxKaExp) {
    // numbers for deletion and insertion and Ka are arbitratily chosen
    V = rng.nextInt(44) + 1;
    VRightDel = rng.nextInt(6);
    final int VDInsNum = rng.nextInt(2);
    for (int i = 0; i < VDInsNum; i++) {
      VDIns += randomBase();
    }
    DLeftDel = rng.nextInt(6);
    D = rng.nextInt(27) + 1;
    DRightDel = rng.nextInt(6);
    final int DJInsNum = rng.nextInt(2);
    for (int i = 0; i < DJInsNum; i++) {
      DJIns += randomBase();
    }
    JLeftDel = rng.nextInt(6);
    J = rng.nextInt(6) + 1;
    newKa(minKaExp, maxKaExp);
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
