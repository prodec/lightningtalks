var socket;



function setup() {
  createCanvas(600, 600);
  background(0);

  socket = io.connect('http://localhost:3000');

  socket.on('mouse',
            function(data) {
              console.log("Got: " + data.x + " " + data.y );

              fill(0,0,255);
              noStroke();
              ellipse(data.x, data.y, 50, 50);
            }
           );
}

function draw() {
  //no code
}

function mouseDragged() {
  fill(255);
  noStroke();
  ellipse(mouseX, mouseY, 50, 50);

  sendMouse(mouseX, mouseY);

}

function sendMouse(x, y) {
  console.log("sending " + x + " " + y);

  var data = {
    x: x,
    y: y
  };

  socket.emit('mouse', data);
}
