#eemple 

from brownie import SimpleDAO, accounts, network, Contract
import time
import os

private_key = os.getenv('PRIVATE_KEY')
account = accounts.add(private_key)

def deploy():
    dao_contract = SimpleDAO.deploy("My DAO", {'from': account})
    dao_contract.addMember(account.address, {'from': account})
    time.sleep(1)
    # Adding more accounts to the simulation
    account2 = accounts.add(os.getenv('PRIVATE_KEY_2'))
    dao_contract.addMember(account2.address, {'from': account})
    time.sleep(1)
    account3 = accounts.add(os.getenv('PRIVATE_KEY_3'))
    dao_contract.addMember(account3.address, {'from': account})
    time.sleep(1)
    # Adding a proposal from each account
    dao_contract.addProposal("Proposal 1", "Description for proposal 1", {'from': account})
    time.sleep(1)
    dao_contract.addProposal("Proposal 2", "Description for proposal 2", {'from': account2})
    time.sleep(1)
    dao_contract.addProposal("Proposal 3", "Description for proposal 3", {'from': account3})
    time.sleep(1)
    # Each account votes on a proposal
    dao_contract.vote(0, {'from': account})
    time.sleep(1)
    dao_contract.vote(1, {'from': account2})
    time.sleep(1)
    dao_contract.vote(2, {'from': account3})
    time.sleep(1)

    proposal_0 = dao_contract.proposals(0)
    print(f"Description : {proposal_0[1]}")

    return dao_contract

def main():
    deploy()