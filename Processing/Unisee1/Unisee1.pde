import hypermedia.video.*;
import oscP5.*;
import netP5.*;
import org.json.*;
OpenCV opencv;

//OSC
OscP5 oscP5;
NetAddress myRemoteLocation;

void setup() {
    frameRate(20);
    //size( 320, 240 );
    size(792, 426);

    // open video stream
    opencv = new OpenCV( this );
    opencv.capture( 792, 426 );
    
    oscP5 = new OscP5(this, 12000);
    myRemoteLocation = new NetAddress("127.0.0.1", 57001);
}

void draw() {

    opencv.read();                               // grab frame from camera
   
    opencv.convert(OpenCV.GRAY);
   
    opencv.absDiff();                            // make the difference between the current image and the image in memory

    opencv.threshold(125);    // set black & white threshold
    
    opencv.blur(OpenCV.GAUSSIAN, 11);
   
    image( opencv.image(), 0, 0 );             // display the result on the bottom right
    
    
    
      stroke(0, 255, 0);
      fill(255, 0, 0);
     // find blobs
    Blob[] blobs = opencv.blobs( 10, (width*height)/4, 2, false, 20 /*OpenCV.MAX_VERTICES*4*/ );
    
    sendBlobs(blobs);
    
    // draw blob results
    for( int i=0; i<blobs.length; i++ ) {
        
        beginShape();
        for( int j=0; j<blobs[i].points.length; j++ ) {
            vertex( blobs[i].points[j].x, blobs[i].points[j].y );
        }
        endShape(CLOSE);
    }
    

}

void keyPressed() {
        
    opencv.remember();  // store the actual image in memory
    
}


void sendBlobs(Blob[] blobs) {
    
    if (blobs.length <= 0) {
        return;
    }
    
    OscMessage myMessage = new OscMessage("/acw");
    myMessage.add("cc");
    myMessage.add(15);
        
    try{
        JSONObject parentJSON = new JSONObject();
        JSONArray blobArray = new JSONArray();
        
        for( int i=0; i<blobs.length; i++ ) {
            JSONObject jsonBlob = new JSONObject();
        
            JSONObject[] blobVertices = new JSONObject[blobs[i].points.length];
        
            for( int j=0; j<blobs[i].points.length; j++ ) {
                JSONObject point = new JSONObject();
                point.put("x", blobs[i].points[j].x);
                point.put("y", blobs[i].points[j].y);
                blobVertices[j] = point;
            }
        
            jsonBlob.put("vertices", blobVertices);
            blobArray.put(jsonBlob);
        
        }   
        parentJSON.put("blobs", blobArray);
         myMessage.add(parentJSON.toString());
         oscP5.send(myMessage, myRemoteLocation);
    } catch (Exception e) {
        System.err.println("Error writing JSON: " + e.getMessage());
    }
    
       
}

/*
void sendOSCMessage(float val, float[] binVals) {
  OscMessage myMessage = new OscMessage("/acw");
  myMessage.add("cc");
  myMessage.add(15);
  myMessage.add(binVals.length);

  myMessage.add(val);
  if (binVals != null) {
    myMessage.add(binVals);
  }

  // send the message 
  oscP5.send(myMessage, myRemoteLocation); 
  println("sent message: " + myMessage);
}
*/