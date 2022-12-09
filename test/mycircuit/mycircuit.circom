pragma circom 2.0.0;

template MyCircuit() {
    signal input x;
    signal output out;
    signal var1;

    var1 <== x * x;
    out <== var1 * x + x + 5;
}

component main = MyCircuit();