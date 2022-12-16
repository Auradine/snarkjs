all: compile

circom:
	circom -p bls12381 test/mycircuit/mycircuit.circom --r1cs --wasm --sym --c -o test/mycircuit
	snarkjs r1cs export json test/mycircuit/mycircuit.r1cs mycircuit.r1cs.json
	snarkjs r1cs print test/mycircuit/mycircuit.r1cs
	snarkjs r1cs info test/mycircuit/mycircuit.r1cs

# witness: circom
# 	node mycircuit_js/generate_witness.js mycircuit_js/mycircuit.wasm input.json ../../witness.wtns

snarkjs: ptau phase2 proof verify

ptau:
	snarkjs powersoftau new bls12381 2 pot12_0000.ptau -v
	snarkjs powersoftau prepare phase2 pot12_0000.ptau pot12_0000_final.ptau -v
	snarkjs powersoftau export json pot12_0000_final.ptau pot12_0000_final.ptau.json
#   [ERROR] snarkJS: This file has no contribution! It cannot be used in production

	snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v
	snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
	snarkjs powersoftau export json pot12_final.ptau pot12_final.ptau.json
	snarkjs powersoftau verify pot12_final.ptau

phase2:
	snarkjs groth16 setup test/mycircuit/mycircuit.r1cs pot12_final.ptau mycircuit_0000.zkey
	snarkjs zkey contribute mycircuit_0000.zkey mycircuit_0001.zkey --name="1st Contributor Name" -v
	snarkjs zkey verify test/mycircuit/mycircuit.r1cs pot12_final.ptau mycircuit_0001.zkey
	snarkjs zkey export json mycircuit_0001.zkey mycircuit_0001.zkey.json

proof:
	snarkjs groth16 prove mycircuit_0001.zkey witness.wtns proof.json public.json
	snarkjs wtns export json witness.wtns witness.wtns.json

verify:
	snarkjs zkey export verificationkey mycircuit_0001.zkey verification_key.json
	snarkjs groth16 verify verification_key.json public.json proof.json
