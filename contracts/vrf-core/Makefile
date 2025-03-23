SENDER=TODO

# === RPC ===
RNDM_RPC_URL=http://167.172.174.224:8547
SEPOLIA_RPC_URL=https://arbitrum-sepolia-rpc.publicnode.com
ETH_SEPOLIA_RPC_URL=https://ethereum-sepolia-rpc.publicnode.com
OPT_SEPOLIA_RPC_URL=https://optimism-sepolia-rpc.publicnode.com

# === VERIFICATION LIB ===
ARB_VERIFICATION_LIB=0xAB6729F68CECD58D718693d98108AaaE0bf72b2A
RNDM_VERIFICATION_LIB=0x90C95CD5980001b55EE0e54845d0daa9dA93d64E
ETH_VERIFICATION_LIB=0x8368725aA2F7e8651b1CBa63a5d701ab72f5D429
OPT_VERIFICATION_LIB=0x8368725aA2F7e8651b1CBa63a5d701ab72f5D429

# === MAILBOX ===
ARB_MAILBOX=0x598facE78a4302f11E3de0bee1894Da0b2Cb71F8
RNDM_MAILBOX=0xbE431E0aaEFeC6Ce80071498bCbEd0452011DC41
ETH_MAILBOX=0xfFAEF09B3cd11D9b20d1a19bECca54EEC2884766
OPT_MAILBOX=0x6966b0E55883d49BFB24539356a2f8A673E02039

# === REQUEST ===
ARB_REQUEST=0x008635105b348396B6ccD18BB715A9b6Db0E0D12
ETH_REQUEST=0xa6334941d20b76af46379606a80F73a9c1406586
OPT_REQUEST=0xa6334941d20b76af46379606a80F73a9c1406586


# === CORE ===
RNDM_CORE=0x9bF90104DC52b645038780f5e4410eC036DD273d

# === ISM ===
ARB_VRF_ISM=0x1DEbF254fA84C8AF4aE4E26A1A5C53A139d4E58C
ETH_VRF_ISM=0xa57B242453b730a55DF8bB4E84301FBAA5B51e86
OPT_VRF_ISM=0xa57B242453b730a55DF8bB4E84301FBAA5B51e86

# === CHAIN ID ===
ARB_CHAIN_ID=421614
RNDM_CHAIN_ID=112000
ETH_CHAIN_ID=11155111
OPT_CHAIN_ID=11155420

# === MOCKS ===
ARB_VRF_CLIENT=0x64842c038db9aF44D29D2A27EF50dBBa6f7E43Bb
ETH_VRF_CLIENT=0xBD16beD149AA683252748C498F348Fe4b0b1A031
OPT_VRF_CLIENT=0xBD16beD149AA683252748C498F348Fe4b0b1A031

build:
	forge clean && forge build

deploy-vrf-request: build
	ADMIN=$(SENDER) forge script --chain $(RNDM_CHAIN_ID) script/VRFRequest.s.sol:VRFRequestV1Script --rpc-url $(RPC_URL) --sender $(SENDER) --broadcast -vvvv --interactives 1 --with-gas-price 1gwei --priority-gas-price 1gwei --skip-simulation

deploy-vrf-core: build
	ADMIN=$(SENDER) VERIFICATION_LIB=$(RNDM_VERIFICATION_LIB) MAILBOX=$(RNDM_MAILBOX) forge script --chain $(RNDM_CHAIN_ID) script/VRFCore.s.sol:VRFCoreV1Script --rpc-url $(RNDM_RPC_URL) --sender $(SENDER) --broadcast -vvvv --interactives 1 --with-gas-price 1gwei --priority-gas-price 1gwei --skip-simulation


# === Deploy Request ===

deploy-vrf-req-arb: build
	ADMIN=$(SENDER) VERIFICATION_LIB=$(ARB_VERIFICATION_LIB) ISM=$(ARB_VRF_ISM) MAILBOX=$(ARB_MAILBOX) CHAIN_ID=$(ARB_CHAIN_ID) RANDOM_CORE=$(RNDM_CORE) forge script --chain $(ARB_CHAIN_ID) script/VRFRequest.s.sol:VRFRequestV1Script --rpc-url $(SEPOLIA_RPC_URL) --sender $(SENDER) --broadcast -vvvv --interactives 1

deploy-vrf-req-eth: build
	ADMIN=$(SENDER) VERIFICATION_LIB=$(ETH_VERIFICATION_LIB) ISM=$(ETH_VRF_ISM) MAILBOX=$(ETH_MAILBOX) CHAIN_ID=$(ETH_CHAIN_ID) RANDOM_CORE=$(RNDM_CORE) forge script --chain $(ETH_CHAIN_ID) script/VRFRequest.s.sol:VRFRequestV1Script --rpc-url $(ETH_SEPOLIA_RPC_URL) --sender $(SENDER) --broadcast -vvvv --interactives 1

deploy-vrf-req-opt: build
	ADMIN=$(SENDER) VERIFICATION_LIB=$(OPT_VERIFICATION_LIB) ISM=$(OPT_VRF_ISM) MAILBOX=$(OPT_MAILBOX) CHAIN_ID=$(OPT_CHAIN_ID) RANDOM_CORE=$(RNDM_CORE) forge script --chain $(OPT_CHAIN_ID) script/VRFRequest.s.sol:VRFRequestV1Script --rpc-url $(OPT_SEPOLIA_RPC_URL) --sender $(SENDER) --broadcast -vvvv --interactives 1


# === Deploy Verification Lib ===
deploy-vrf-verification-lib-rnd: build
	forge script --chain $(RNDM_CHAIN_ID) script/VRFVerificationLib.s.sol:VRFVerificationLibScript --rpc-url $(RPC_URL) --sender $(SENDER) --broadcast -vvvv --interactives 1

deploy-vrf-verification-lib-arb: build
	forge script --chain $(ARB_CHAIN_ID) script/VRFVerificationLib.s.sol:VRFVerificationLibScript --rpc-url $(SEPOLIA_RPC_URL) --sender $(SENDER) --broadcast -vvvv --interactives 1

deploy-vrf-verification-lib-eth: build
	forge script --chain $(ETH_CHAIN_ID) script/VRFVerificationLib.s.sol:VRFVerificationLibScript --rpc-url $(ETH_SEPOLIA_RPC_URL) --sender $(SENDER) --broadcast -vvvv --interactives 1

deploy-vrf-verification-lib-opt: build
	forge script --chain $(OPT_CHAIN_ID) script/VRFVerificationLib.s.sol:VRFVerificationLibScript --rpc-url $(OPT_SEPOLIA_RPC_URL) --sender $(SENDER) --broadcast -vvvv --interactives 1


# === Deploy ISM ===

deploy-vrf-ism-arb: build
	ADMIN=$(SENDER) forge script --chain $(ARB_CHAIN_ID) script/VRFISM.s.sol:VRFInterchainSecurityModuleScript --rpc-url $(SEPOLIA_RPC_URL) --sender $(SENDER) --broadcast -vvvv --interactives 1

deploy-vrf-ism-eth: build
	ADMIN=$(SENDER) forge script --chain $(ETH_CHAIN_ID) script/VRFISM.s.sol:VRFInterchainSecurityModuleScript --rpc-url $(ETH_SEPOLIA_RPC_URL) --sender $(SENDER) --broadcast -vvvv --interactives 1

deploy-vrf-ism-opt: build
	ADMIN=$(SENDER) forge script --chain $(OPT_CHAIN_ID) script/VRFISM.s.sol:VRFInterchainSecurityModuleScript --rpc-url $(OPT_SEPOLIA_RPC_URL) --sender $(SENDER) --broadcast -vvvv --interactives 1


# === VRF Core Management ===
add-executor: build
	VRF_CORE=$(RNDM_CORE) EXECUTOR=0x7682df12Dc31d5Dc6A1057958887d1Ad6F4Eed19 forge script --chain $(RNDM_CHAIN_ID) script/VRFCore.s.sol:VRFCoreSetupExecutorScript --rpc-url $(RNDM_RPC_URL) --sender $(SENDER) --broadcast -vvvv --interactives 1

add-relayer: build
	VRF_CORE=$(RNDM_CORE) RELAYER=0x4A9ef784031E55Bb6a06fDcE8f099028f5810B50 forge script --chain $(RNDM_CHAIN_ID) script/VRFCore.s.sol:VRFCoreSetupRelayerScript --rpc-url $(RNDM_RPC_URL) --sender $(SENDER) --broadcast -vvvv --interactives 1

upgrade-vrf-core: build
	VRF_CORE=$(RNDM_CORE) forge script --chain $(RNDM_CHAIN_ID) script/VRFCore.s.sol:VRFCoreUpgradeScript --rpc-url $(RNDM_RPC_URL) --sender $(SENDER) --broadcast -vvvv --interactives 1 --skip-simulation


# === VRF Request Management ===
set-random-network-recipient: build
	VRF_REQUEST=$(ARB_REQUEST) RECIPIENT=$(RNDM_CORE) forge script --chain $(ARB_CHAIN_ID) script/VRFRequest.s.sol:VRFRequestV1SetRandomNetworkRecipientScript --rpc-url $(SEPOLIA_RPC_URL) --sender $(SENDER) --broadcast -vvvv --interactives 1


# === Mocks ===
mock-vrf-request-client-arb: build
	VRF_REQUEST=$(ARB_REQUEST) forge script --chain $(ARB_CHAIN_ID) script/MockVRFRequestClient.s.sol:VRFRequestClientScript --rpc-url $(SEPOLIA_RPC_URL) --sender $(SENDER) --broadcast -vvvv --interactives 1

mock-vrf-request-client-eth: build
	VRF_REQUEST=$(ETH_REQUEST) forge script --chain $(ETH_CHAIN_ID) script/MockVRFRequestClient.s.sol:VRFRequestClientScript --rpc-url $(ETH_SEPOLIA_RPC_URL) --sender $(SENDER) --broadcast -vvvv --interactives 1

mock-vrf-request-client-opt: build
	VRF_REQUEST=$(OPT_REQUEST) forge script --chain $(OPT_CHAIN_ID) script/MockVRFRequestClient.s.sol:VRFRequestClientScript --rpc-url $(OPT_SEPOLIA_RPC_URL) --sender $(SENDER) --broadcast -vvvv --interactives 1

mock-vrf-request-client-request-randomness: build
	FEE=1 VRF_CLIENT=$(ARB_VRF_CLIENT) forge script --chain $(ARB_CHAIN_ID) script/MockVRFRequestClient.s.sol:VRFRequestClientRequestRandomnessScript --rpc-url $(SEPOLIA_RPC_URL) --sender $(SENDER) --broadcast -vvvv --interactives 1

mock-vrf-request-client-get-randomness:
	VRF_CLIENT=$(ARB_VRF_CLIENT) REQUEST_ID=0xc60370653047ae33d26c7098d054c4a9271d4d161e1659e8de770e5b7e1ceaab forge script --chain $(ARB_CHAIN_ID) script/MockVRFRequestClient.s.sol:VRFRequestClientGetRandomnessScript --rpc-url $(SEPOLIA_RPC_URL) --sender $(SENDER) --broadcast -vvvv --interactives 1

# === Mailbox ===
mailbox-process: build
	MAILBOX=$(ARB_MAILBOX) forge script --chain $(ARB_CHAIN_ID) script/VRFRequest.s.sol:VRFRequestV1MailboxScript --rpc-url $(SEPOLIA_RPC_URL) --sender $(SENDER) --broadcast -vvvv --interactives 1


.PHONY: test
test: build
	forge test -vvv --summary