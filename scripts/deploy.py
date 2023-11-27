#eemple 

from brownie import DaisyworldNFT, accounts, network, Contract
import time
import os

private_key = os.getenv('PRIVATE_KEY')
account = accounts.add(private_key)

def deploy():
    nft_contract = DaisyworldNFT.deploy(account, 100, {'from': account})
    nft_contract.mintDaisy(0, {'from': account})
    time.sleep(1)

    return nft_contract

def main():
    deploy()