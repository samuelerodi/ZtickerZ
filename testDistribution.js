
var iterations = 100000;
var N = 100;
var l = 4;
var m = Math.floor(N/l);

function mod(x, n) {
 return (x % n + n) % n
}

var out = {};
for(var i = 0; i < N; i++){
   out[i]=0;
}

for (var i = 0; i<iterations; i++) {

  var a = Math.floor(Math.random() * N) ;
  var b = Math.floor(Math.random() * (m + 1));
  var c = Math.floor(Math.random() * (l + 1));

  var stn = mod(-Math.ceil(Math.abs(a + (b*c) - N + 0.5)), N);
  // var stn = a + (b*c);
  // if (stn>=N)
  //   stn = mod(N - 1 + (mod(-stn,  N)), N);


  out[stn]++;
}

for(var i = 0; i < N; i++){
   out[i]=out[i]/iterations;
}

console.log(out)
