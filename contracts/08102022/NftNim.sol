/*
NftNim

SPDX-License-Identifier: MIT
*/

pragma solidity 0.8.15;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import './PairingNim.sol';

contract NftNim is ERC721URIStorage, Ownable {
  struct EntityNim {
    string nimMahasiswa;
    string universitas;
    string kodeProdi;
    uint expired;
    bool isBurned;
    address walletMahasiswa;
  }

  using Counters for Counters.Counter;
  Counters.Counter private tokenIds_;

  address private diktiAddr;
  mapping(address => uint256) private walletMinted;
  mapping(uint256 => EntityNim) private idNim;

  constructor() payable ERC721('NimMahasiswa', 'NIMHS') {
    diktiAddr = owner();
  }
 
  function mint(string calldata uri_, string memory nim_, string memory universitas_, string memory kodeProdi_) public returns (uint256) {
   uint256 newItemId = tokenIds_.current();
   _safeMint(diktiAddr, newItemId);
   _setTokenURI(newItemId, uri_);
   idNim[newItemId].nimMahasiswa = nim_;
   idNim[newItemId].universitas = universitas_;
   idNim[newItemId].kodeProdi = kodeProdi_;
   idNim[newItemId].isBurned = false;
   idNim[newItemId].expired = block.timestamp + 24 weeks;
   
   tokenIds_.increment();
   return newItemId;
  }
  
  function transferNim(address to_, uint256 tokenId_, string memory nim_, string memory universitas_) public returns (uint256 token) {
    require(walletMinted[to_] < 1, 'sertifikat hanya diterbitkan 1 kali');
    require(keccak256(abi.encodePacked(idNim[tokenId_].nimMahasiswa)) == keccak256(abi.encodePacked(nim_)), 'nim mahasiswa tidak sesuai');
    require(keccak256(abi.encodePacked(idNim[tokenId_].universitas)) == keccak256(abi.encodePacked(universitas_)), 'universitas tidak sesuai');
    require(!idNim[tokenId_].isBurned, 'ijazah sudah tidak valid');
    safeTransferFrom(diktiAddr, to_, tokenId_);
    walletMinted[to_]++;
    return tokenId_;
  }

  function getNim(uint256 tokenId_, string memory universitas_) public view returns (EntityNim memory mahasiswa) {
    require(keccak256(abi.encodePacked(idNim[tokenId_].universitas)) == keccak256(abi.encodePacked(universitas_)), 'universitas tidak sesuai');

    return idNim[tokenId_];
  }

  function burnAfterTransfer(uint256 tokenId_) public onlyOwner {
    idNim[tokenId_].isBurned = true;
  }

  function burn(uint256 tokenId_) public onlyOwner {
    super._burn(tokenId_);
    idNim[tokenId_].isBurned = true;
  }
}