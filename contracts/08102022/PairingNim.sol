/*
PairingNim

SPDX-License-Identifier: MIT
*/

pragma solidity 0.8.15;

import '@openzeppelin/contracts/access/Ownable.sol';
import './Sertifikat.sol';

contract PairingNim is Ownable {
    struct EntityPairing {
        string nimMahasiswa;
        string ninaMahasiswa;
        string kodeProdi;
        uint256 tokenId;
        uint256 listPointer;
    }

    mapping(string => mapping(string => mapping(string => bool))) private nimInserted;
    mapping(string => EntityPairing[]) private daftarMahasiswaLulus;
    mapping(string => mapping(string => mapping(string => EntityPairing))) private singleMahasiswa;
    mapping(string => mapping(string => mapping(string => uint256))) private tokenIdMahasiswa;

    EntityPairing private mahasiswaLulus;
    EntityPairing[] private allMahasiswa;
    Sertifikat private sertifikat;
    string private nimLulus;
    address private diktiAddr = owner();
    
    constructor(address sertifikatContract) {
        sertifikat = Sertifikat(sertifikatContract);
    }

    function tambahAllMahasiswa(string[][] memory mahasiswa_, string memory universitas_, string memory kodeProdi_) public returns (bool success) {
        for (uint i = 0; i < mahasiswa_.length; i++){
            tambahMahasiswa(universitas_, mahasiswa_[i][0], mahasiswa_[i][1], kodeProdi_);
        }
        return true;
    }

    function tambahMahasiswa (
        string memory universitas_,
        string memory nim_,
        string memory nina_,
        string memory kodeProdi_
    ) public {
        require(!nimInserted[universitas_][kodeProdi_][nim_], "Nim pada prodi ini sudah ditambahkan");
        uint256 tokenId = sertifikat.mint("", nim_, nina_, universitas_, kodeProdi_);

        mahasiswaLulus.nimMahasiswa = nim_;
        mahasiswaLulus.ninaMahasiswa = nina_;
        mahasiswaLulus.kodeProdi = kodeProdi_;
        mahasiswaLulus.tokenId = tokenId;
        
        daftarMahasiswaLulus[universitas_].push(mahasiswaLulus);
        mahasiswaLulus.listPointer = daftarMahasiswaLulus[universitas_].length -1;
        singleMahasiswa[universitas_][kodeProdi_][nim_] = mahasiswaLulus;
        tokenIdMahasiswa[universitas_][kodeProdi_][nim_] = tokenId;

        nimInserted[universitas_][kodeProdi_][nim_] = true;
    }

    function cetakIjazah(uint256 tokenId_, string memory nim_, string memory nina_, string memory universitas_, string memory kodeProdi_) public returns (bool isMhs) {
      require(keccak256(abi.encodePacked(singleMahasiswa[universitas_][kodeProdi_][nim_].nimMahasiswa)) == keccak256(abi.encodePacked(nim_)), 'nim mahasiswa tidak sesuai');
      require(keccak256(abi.encodePacked(singleMahasiswa[universitas_][kodeProdi_][nim_].ninaMahasiswa)) == keccak256(abi.encodePacked(nina_)), 'nina mahasiswa tidak sesuai');
      require(keccak256(abi.encodePacked(singleMahasiswa[universitas_][kodeProdi_][nim_].kodeProdi)) == keccak256(abi.encodePacked(kodeProdi_)), 'kodeProdi tidak sesuai');
    
      return sertifikat.transferSertifikat_(msg.sender, tokenId_);
    }
    
    function isMahasiswaLulus(string memory universitas_, string memory kodeProdi_, string memory nim_) public view returns (bool isMhs) {
        return singleMahasiswa[universitas_][kodeProdi_][nim_].tokenId > 0;
    }

    function getMahasiswa(string memory universitas_, string memory nim_, string memory kodeProdi_) public view returns (EntityPairing memory mahasiswa) {
        require(singleMahasiswa[universitas_][kodeProdi_][nim_].tokenId > 0, "mahasiswa not found");
        return singleMahasiswa[universitas_][kodeProdi_][nim_];
    }
    
    function getAllMahasiswa(string memory universitas_) public view returns (EntityPairing[] memory mahasiswa) {
        require(daftarMahasiswaLulus[universitas_].length > 0, "mahasiswa not found");
        return daftarMahasiswaLulus[universitas_];
    }
    
    function getTokenIdMhs(string memory universitas_, string memory nim_, string memory kodeProdi_) public view returns (uint256 tokenId) {
        require(tokenIdMahasiswa[universitas_][kodeProdi_][nim_] > 0, "token not found");
        return tokenIdMahasiswa[universitas_][kodeProdi_][nim_];
    }
}
