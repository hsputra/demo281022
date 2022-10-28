/*
Reservasi

SPDX-License-Identifier: MIT
*/

pragma solidity 0.8.15;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';

contract Sertifikat is IERC721Receiver, ERC721URIStorage, Ownable {
  struct EntitySertifikat {
    string nimMahasiswa;
    string ninaMahasiswa;
    string universitas;
    string kodeProdi;
    bool isBurned;
    address walletAddr;
  }

  function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
  }

  using Counters for Counters.Counter;
  Counters.Counter private tokenIds_;

  address private diktiAddr;
  mapping(address => uint256) private walletMinted;
  mapping(uint256 => EntitySertifikat) private idSertifikat;

  constructor() payable ERC721('Sertifikat', 'SRTK') {
    diktiAddr = owner();
  }
 
  function mint(string calldata uri_, string memory nim_, string memory nina_, string memory universitas_, string memory kodeProdi_) external returns (uint256) {
    tokenIds_.increment();
    uint256 newItemId = tokenIds_.current();
    _safeMint(diktiAddr, newItemId);
    _setTokenURI(newItemId, uri_);
    idSertifikat[newItemId].nimMahasiswa = nim_;
    idSertifikat[newItemId].ninaMahasiswa = nina_;
    idSertifikat[newItemId].universitas = universitas_;
    idSertifikat[newItemId].isBurned = false;
    idSertifikat[newItemId].kodeProdi = kodeProdi_;
    idSertifikat[newItemId].walletAddr = diktiAddr;

    return newItemId;
  }
  
  function transferSertifikat_(address to_, uint256 tokenId_) public returns (bool isTransferred) {
    require(walletMinted[to_] < 1, 'sertifikat hanya diterbitkan 1 kali');
    require(!idSertifikat[tokenId_].isBurned, 'ijazah sudah tidak valid');
    _transfer(diktiAddr, to_, tokenId_);
    idSertifikat[tokenId_].walletAddr = to_;
    walletMinted[to_]++;
    return true;
  }

  function getSertifikat(uint256 tokenId_, string memory universitas_) public view returns (EntitySertifikat memory mahasiswa) {
    require(keccak256(abi.encodePacked(idSertifikat[tokenId_].universitas)) == keccak256(abi.encodePacked(universitas_)), 'universitas tidak sesuai');

    return idSertifikat[tokenId_];
  }

  function hapusIjazah(uint256 tokenId_) public onlyOwner {
    if(idSertifikat[tokenId_].walletAddr != diktiAddr) {
      _transfer(idSertifikat[tokenId_].walletAddr, diktiAddr, tokenId_);
    }
    _burn(tokenId_);
    idSertifikat[tokenId_].isBurned = true;
  }
}