-- Ragnall Muhammad Al Fath (2306210550)
-- Dionysius Davis (2306213836)
-- Vissuta Gunawan Lim (2306214656)
-- Argya Farel Kasyara (2306152424)

-- Membuat Schema Sijarta
CREATE SCHEMA SIJARTA;

-- Mengubah search_path dari public ke sijarta
SET search_path to SIJARTA;

-- Membuat Tabel setiap class di Sijarta beserta Atributnya
-- 1
CREATE TABLE USERS(
    id_user UUID,
    nama varchar,
    jenis_kelamin char(1) CHECK (jenis_kelamin IN ('L', 'P')),
    no_hp varchar,
    pwd varchar,
    tgl_lahir DATE,
    alamat varchar,
    saldomypay DECIMAL,
    PRIMARY KEY (id_user)
);
-- 2
CREATE TABLE PELANGGAN(
    id_user UUID,
    level varchar,
	PRIMARY KEY (id_user),
    FOREIGN KEY (id_user) REFERENCES USERS(id_user)
);
-- 3
CREATE TABLE PEKERJA(
    id_user UUID,
    nama_bank varchar,
    nomor_rekening varchar,
    npwp varchar,
    link_foto varchar,
    rating float,
    jml_pesanan_selesai INT,
	PRIMARY KEY (id_user),
    FOREIGN KEY (id_user) REFERENCES USERS(id_user)
);
-- 4
CREATE TABLE TR_MYPAY(
    id_tr_mypay UUID,
    id_user UUID,
    tgl DATE,
    nominal DECIMAL,
    id_kategori_tr_mypay UUID,
    PRIMARY KEY (id_tr_mypay),
    FOREIGN KEY (id_user) REFERENCES USERS(id_user),
    FOREIGN KEY (id_kategori_tr_mypay) REFERENCES KATEGORI_TR_MYPAY(id_kategori_tr_mypay)
);
-- 5
CREATE TABLE KATEGORI_TR_MYPAY(
    id_kategori_tr_mypay UUID,
    nama varchar,
    PRIMARY KEY (id_kategori_tr_mypay)
);
-- 6
CREATE TABLE KATEGORI_JASA(
    id_kategori_jasa UUID,
    nama_kategori varchar,
    PRIMARY KEY (id_kategori_jasa)
);
-- 7
CREATE TABLE PEKERJA_KATEGORI_JASA(
    id_pekerja UUID,
    id_kategori_jasa UUID,
    FOREIGN KEY (id_pekerja) REFERENCES PEKERJA(id_user),
    FOREIGN KEY (id_kategori_jasa) REFERENCES KATEGORI_JASA(id_kategori_jasa)
);
-- 8
CREATE TABLE SUBKATEGORI_JASA(
    id_subkategori UUID,
    nama_subkategori varchar,
    deskripsi TEXT,
    id_kategori_jasa UUID,
    PRIMARY KEY (id_subkategori),
    FOREIGN KEY (id_kategori_jasa) REFERENCES KATEGORI_JASA(id_kategori_jasa)
);
-- 9
CREATE TABLE SESI_LAYANAN(
    id_subkategori UUID,
    sesi INT,
    harga DECIMAL,
    PRIMARY KEY (id_subkategori, sesi),
    FOREIGN KEY (id_subkategori) REFERENCES SUBKATEGORI_JASA(id_subkategori)
);
-- 10
CREATE TABLE DISKON(
    kode varchar(50),
    potongan DECIMAL not null CHECK (potongan >= 0),
    min_tr_pemesanan INT not null CHECK (min_tr_pemesanan >= 0),
    PRIMARY KEY (kode)
);
-- 11
CREATE TABLE VOUCHER(
    kode varchar,
    jml_hari_berlaku INT not null CHECK (jml_hari_berlaku >= 0),
    kuota_penggunaan INT,
    harga DECIMAL not null CHECK (harga >= 0),
    PRIMARY KEY (kode),
    FOREIGN KEY (kode) REFERENCES DISKON(kode)
);
-- 12
CREATE TABLE PROMO(
    kode varchar,
    tgl_akhir_berlaku DATE not null,
    PRIMARY KEY (kode),
    FOREIGN KEY (kode) REFERENCES DISKON(kode) 
);
-- 13
CREATE TABLE TR_PEMBELIAN_VOUCHER(
    id_tr_pembelian_voucher UUID,
    tgl_awal DATE not null,
    tgl_akhir DATE not null,
    telah_digunakan INT not null CHECK (telah_digunakan >= 0),
    id_pelanggan UUID,
    id_voucher varchar,
    id_metode_bayar UUID,
    PRIMARY KEY (id_tr_pembelian_voucher),
    FOREIGN KEY (id_pelanggan) REFERENCES PELANGGAN(id_user),
    FOREIGN KEY (id_voucher) REFERENCES VOUCHER(kode),
    FOREIGN KEY (id_metode_bayar) REFERENCES METODE_BAYAR(id_metode_bayar)
);
-- 14
CREATE TABLE TR_PEMESANAN_JASA(
    id_tr_pemesanan_jasa UUID,
    tgl_pemesanan DATE not null,
    tgl_pekerjaan DATE not null,
    waktu_pekerjaan timestamp not null,
    total_biaya DECIMAL not null CHECK (total_biaya >= 0),
    id_pelanggan UUID,
    id_pekerja UUID,
    id_subkategori UUID,
    sesi INT,
    id_diskon varchar(50),
    id_metode_bayar UUID,
    PRIMARY KEY (id_tr_pemesanan_jasa),
    FOREIGN KEY (id_pelanggan) REFERENCES PELANGGAN(id_user),
    FOREIGN KEY (id_pekerja) REFERENCES PEKERJA(id_user),
    FOREIGN KEY (id_subkategori, sesi) REFERENCES SESI_LAYANAN(id_subkategori, sesi),
    FOREIGN KEY (id_diskon) REFERENCES DISKON(kode),
    FOREIGN KEY (id_metode_bayar) REFERENCES METODE_BAYAR(id_metode_bayar)
);
-- 15
CREATE TABLE METODE_BAYAR(
    id_metode_bayar UUID,
    nama varchar not null,
    PRIMARY KEY (id_metode_bayar)
);
-- 16
CREATE TABLE STATUS_PESANAN(
    id_status UUID,
    status varchar(50) not null,
    PRIMARY KEY (id_status)
);
-- 17
CREATE TABLE TR_PEMESANAN_STATUS(
    id_tr_pemesanan_jasa UUID,
    id_status UUID,
    tgl_waktu timestamp not null,
    PRIMARY KEY (id_tr_pemesanan_jasa, id_status),
    FOREIGN KEY (id_tr_pemesanan_jasa) REFERENCES TR_PEMESANAN_JASA(id_tr_pemesanan_jasa),
    FOREIGN KEY (id_status) REFERENCES STATUS_PESANAN(id_status)
);
-- 18
CREATE TABLE TESTIMONI(
    id_tr_pemesanan_jasa UUID,
    tgl DATE,
    teks TEXT,
    rating INT not null DEFAULT 0,
    PRIMARY KEY (id_tr_pemesanan_jasa, tgl),
    FOREIGN KEY (id_tr_pemesanan_jasa) REFERENCES TR_PEMESANAN_JASA(id_tr_pemesanan_jasa)
);

-- Menambahkan dummy data untuk setiap kelas sijarta sesuai ketentuan

INSERT INTO USERS VALUES ('8192ca83-c52d-4350-8fa5-64b09cfc96b5','Bruno Fernandes','L','(+44) 7872 834 320','fZrq#x2b*wW49jm.c8C,V^','1994-09-08 00:00:00','12 Maple Street, Manchester, M1 1AA',23456789),
	('73215f43-e03b-45be-8808-5d1c48a86b17','Alejandro Garnacho','L','(+44) 7879 570 499','e8R;>J9dS=y+6MZxUf3P/[','2004-07-01 00:00:00','45 Oak Lane, Manchester, M2 2BB',57891234),
	('1dbaa406-59e3-40b2-bff2-2e6cbf22d690','Kobbie Mainoo','L','(+44) 7749 610 95','ad4mN/j:{2vD3[%+cPCT7>','2005-10-19 00:00:00','78 Pine Road, Manchester, M3 3CC',34567890),
	('53ce366d-1b6b-4570-a75b-9af57bf3da57','Rasmus Hojlund','L','(+44) 7049 670 617','dS`=G]v6jVL</hsU"xX!,{','2003-02-04 00:00:00','34 Birch Avenue, Manchester, M4 4DD',78123456),
	('96b3c2b0-9a2c-4e4f-8fef-21043d66b421','Amad Diallo','L','(+44) 7719 407 629','B_+zg4*$A"f]#2{3&aeq~Y','2002-07-04 00:00:00','56 Cedar Close, Manchester, M5 5EE',45678901),
	('df6e4bf7-ad28-4444-aefe-31a4d00c0d7b','Lisandro Martinez','L','(+44) 7744 346 372','MTA[BX8ya)j<gLzRnUP?!6','1998-02-18 00:00:00','22 Elm Street, Manchester, M6 6FF',89012345),
	('b81696c4-5dda-45db-b34f-0e1b4676b579','Matthijs de Ligt','L','(+44) 7917 701 015','u?]%rcfZ,2sw&m^k8TW)_9','1999-08-06 00:00:00','90 Willow Way, Manchester, M7 7GG',12345678),
	('9eecc737-928e-46ab-97c5-b91168b934dc','Diogo Dalot','L','(+44) 7937 797 989','G3`hM]{b-sygK~'')FaCB^w','1999-03-18 00:00:00','11 Ash Road, Manchester, M8 8HH',66789012),
	('1b835a8e-523c-4eac-9839-e867bdf07ba2','Noussair Mazraoui','L','(+44) 7808 304 087','Y>;rT!K''g[pw4B]t?FN@<9','1997-11-14 00:00:00','67 Hazel Drive, Manchester, M9 9II',91234567),
	('60d5d1ec-83b4-497a-a38b-7b56977d6cb0','Andre Onana','L','(+44) 7987 498 043','a_+#DBU.;}%R3''7Fq)mC4-','1996-04-02 00:00:00','8 Chestnut Grove, Manchester, M10 0JJ',37890123);

INSERT INTO PELANGGAN VALUES ('8192ca83-c52d-4350-8fa5-64b09cfc96b5',5),
	('73215f43-e03b-45be-8808-5d1c48a86b17',4),
	('1dbaa406-59e3-40b2-bff2-2e6cbf22d690',3),
	('53ce366d-1b6b-4570-a75b-9af57bf3da57',2),
	('96b3c2b0-9a2c-4e4f-8fef-21043d66b421',1);

INSERT INTO PEKERJA VALUES ('df6e4bf7-ad28-4444-aefe-31a4d00c0d7b','BCA',1234567890,'12.345.678.9-012.345','https://www.example.com/profile-pics/user1.jpg',4.8,72),
	('b81696c4-5dda-45db-b34f-0e1b4676b579','Mandiri',9876543210,'98.765.432.1-098.765','https://www.example.com/profile-pics/user2.jpg',4.7,31),
	('9eecc737-928e-46ab-97c5-b91168b934dc','BNI',1357924680,'11.222.333.4-123.456','https://www.example.com/profile-pics/user3.jpg',4.9,3),
	('1b835a8e-523c-4eac-9839-e867bdf07ba2','BCA',2468135790,'21.333.444.5-234.567','https://www.example.com/profile-pics/user4.jpg',4.3,126),
	('60d5d1ec-83b4-497a-a38b-7b56977d6cb0','Mandiri',1029384756,'34.555.666.7-345.678','https://www.example.com/profile-pics/user5.jpg',4.7,20);

INSERT INTO KATEGORI_TR_MYPAY VALUES ('b9f06546-ea34-49bc-a687-8d0762eeff8d','TopUp'),
('2ee205e3-7cba-4a08-be83-71ca2a4f3a27','Membayar Jasa'),
('29109017-3126-4f25-8387-1f2375c84c60','Transfer'),
('63bcd533-7503-4bb2-90fd-6e62a8d2a374','Isi E-Money'),
('5ee24ccf-95be-4c93-81db-456da27801b3','Bayar Listrik');

INSERT INTO TR_MYPAY VALUES ('67587cb5-4dab-44fd-8ff5-28e3d46cb4a0','8192ca83-c52d-4350-8fa5-64b09cfc96b5','2024-01-15 00:00:00',234567,'b9f06546-ea34-49bc-a687-8d0762eeff8d'),
	('1b8b6cdd-d103-40de-8938-1de27c1a81b0','73215f43-e03b-45be-8808-5d1c48a86b17','2024-02-22 00:00:00',456789,'2ee205e3-7cba-4a08-be83-71ca2a4f3a27'),
	('18e449b0-bbf0-4303-9b9b-9a2a6edc5b9e','1dbaa406-59e3-40b2-bff2-2e6cbf22d690','2024-03-03 00:00:00',678901,'29109017-3126-4f25-8387-1f2375c84c60'),
	('98dad5fd-7430-410d-919d-a6e42a8da9e1','53ce366d-1b6b-4570-a75b-9af57bf3da57','2024-04-18 00:00:00',345678,'63bcd533-7503-4bb2-90fd-6e62a8d2a374'),
	('4542b55c-deba-4ffa-8d64-2fd0895d17b9','96b3c2b0-9a2c-4e4f-8fef-21043d66b421','2024-05-27 00:00:00',987654,'5ee24ccf-95be-4c93-81db-456da27801b3'),
	('94e335ce-2f77-4f77-b67e-bfa2008cecc2','df6e4bf7-ad28-4444-aefe-31a4d00c0d7b','2024-06-11 00:00:00',543210,'b9f06546-ea34-49bc-a687-8d0762eeff8d'),
	('f218607a-10f1-43ec-80ec-d69c4e31f414','b81696c4-5dda-45db-b34f-0e1b4676b579','2024-07-07 00:00:00',123456,'5ee24ccf-95be-4c93-81db-456da27801b3'),
	('803b9598-4d88-4c77-8e26-c4c0b91aa0bd','9eecc737-928e-46ab-97c5-b91168b934dc','2024-08-14 00:00:00',765432,'2ee205e3-7cba-4a08-be83-71ca2a4f3a27'),
	('16fd1f57-3315-43ca-85e9-7715d5dd4980','1b835a8e-523c-4eac-9839-e867bdf07ba2','2024-09-05 00:00:00',876543,'b9f06546-ea34-49bc-a687-8d0762eeff8d'),
	('215ef1d7-e5b5-4448-8a08-ebf0bda85e71','60d5d1ec-83b4-497a-a38b-7b56977d6cb0','2024-10-08 00:00:00',432109,'63bcd533-7503-4bb2-90fd-6e62a8d2a374'),
	('523775bf-d9a1-4805-ab50-45d13fd6f29d','1dbaa406-59e3-40b2-bff2-2e6cbf22d690','2024-07-30 00:00:00',654321,'5ee24ccf-95be-4c93-81db-456da27801b3'),
	('7abb62df-6abb-49e7-a063-4c245927ef04','1b835a8e-523c-4eac-9839-e867bdf07ba2','2024-01-29 00:00:00',890123,'2ee205e3-7cba-4a08-be83-71ca2a4f3a27'),
	('29308b68-e132-4f68-807c-6e53b541e902','b81696c4-5dda-45db-b34f-0e1b4676b579','2024-02-10 00:00:00',321098,'29109017-3126-4f25-8387-1f2375c84c60'),
	('a781db64-e2dc-4692-9043-641fd8c0c326','73215f43-e03b-45be-8808-5d1c48a86b17','2024-03-15 00:00:00',567890,'2ee205e3-7cba-4a08-be83-71ca2a4f3a27'),
	('4e855537-aced-42d5-90fb-a92407ae24b0','9eecc737-928e-46ab-97c5-b91168b934dc','2024-04-25 00:00:00',111222,'63bcd533-7503-4bb2-90fd-6e62a8d2a374'),
	('cde2b6c0-1f3e-4a7b-8418-05d731341dba','8192ca83-c52d-4350-8fa5-64b09cfc96b5','2024-05-01 00:00:00',888888,'29109017-3126-4f25-8387-1f2375c84c60'),
	('858b6cb6-0dcd-4b2b-9400-a356853c6246','96b3c2b0-9a2c-4e4f-8fef-21043d66b421','2024-06-22 00:00:00',222333,'2ee205e3-7cba-4a08-be83-71ca2a4f3a27'),
	('30496cf8-2bfe-4fd2-8cf1-c3bf587d31ae','df6e4bf7-ad28-4444-aefe-31a4d00c0d7b','2024-07-19 00:00:00',999999,'5ee24ccf-95be-4c93-81db-456da27801b3'),
	('ea935bdb-92f5-4459-b382-19470fb67319','53ce366d-1b6b-4570-a75b-9af57bf3da57','2024-08-05 00:00:00',333444,'2ee205e3-7cba-4a08-be83-71ca2a4f3a27'),
	('842928aa-5295-4bdf-ae86-373c29ae5f9e','1b835a8e-523c-4eac-9839-e867bdf07ba2','2024-09-12 00:00:00',777888,'63bcd533-7503-4bb2-90fd-6e62a8d2a374'),
	('1ae9d536-de8e-4b1d-9590-a307a7b12242','b81696c4-5dda-45db-b34f-0e1b4676b579','2024-10-01 00:00:00',222222,'5ee24ccf-95be-4c93-81db-456da27801b3'),
	('15475816-070c-4cc0-9037-ba9774022a0f','60d5d1ec-83b4-497a-a38b-7b56977d6cb0','2024-03-15 00:00:00',444555,'63bcd533-7503-4bb2-90fd-6e62a8d2a374'),
	('832e498e-9084-402a-abcd-f6dcce579319','1dbaa406-59e3-40b2-bff2-2e6cbf22d690','2024-09-19 00:00:00',555666,'b9f06546-ea34-49bc-a687-8d0762eeff8d'),
	('2d4d7365-4ce6-4463-aede-8c201d2b83c2','53ce366d-1b6b-4570-a75b-9af57bf3da57','2024-05-25 00:00:00',666777,'2ee205e3-7cba-4a08-be83-71ca2a4f3a27'),
	('77c1a380-6f51-48b0-98b4-95e6c246da52','96b3c2b0-9a2c-4e4f-8fef-21043d66b421','2024-01-31 00:00:00',888999,'b9f06546-ea34-49bc-a687-8d0762eeff8d');

INSERT INTO KATEGORI_JASA VALUES ('7d2dd61f-c504-4884-ab69-c6721f7778be','Home Cleaning'),
	('ac887a45-11ee-4f05-91f8-73f099220bda','Deep Cleaning'),
	('71045063-cac5-4ac7-b3ec-a378a88846eb','Service AC'),
	('9606390d-a17e-486f-9a11-15c0eb3b1e05','Massage'),
	('83e6c931-8f65-4b5a-98b8-f0de5034fbbe','Hair Care');

INSERT INTO PEKERJA_KATEGORI_JASA VALUES ('df6e4bf7-ad28-4444-aefe-31a4d00c0d7b','7d2dd61f-c504-4884-ab69-c6721f7778be'),
	('b81696c4-5dda-45db-b34f-0e1b4676b579','ac887a45-11ee-4f05-91f8-73f099220bda'),
	('9eecc737-928e-46ab-97c5-b91168b934dc','71045063-cac5-4ac7-b3ec-a378a88846eb'),
	('1b835a8e-523c-4eac-9839-e867bdf07ba2','9606390d-a17e-486f-9a11-15c0eb3b1e05'),
	('60d5d1ec-83b4-497a-a38b-7b56977d6cb0','83e6c931-8f65-4b5a-98b8-f0de5034fbbe'),
	('b81696c4-5dda-45db-b34f-0e1b4676b579','7d2dd61f-c504-4884-ab69-c6721f7778be'),
	('9eecc737-928e-46ab-97c5-b91168b934dc','ac887a45-11ee-4f05-91f8-73f099220bda'),
	('1b835a8e-523c-4eac-9839-e867bdf07ba2','71045063-cac5-4ac7-b3ec-a378a88846eb'),
	('60d5d1ec-83b4-497a-a38b-7b56977d6cb0','9606390d-a17e-486f-9a11-15c0eb3b1e05'),
	('df6e4bf7-ad28-4444-aefe-31a4d00c0d7b','83e6c931-8f65-4b5a-98b8-f0de5034fbbe');

INSERT INTO SUBKATEGORI_JASA VALUES ('a7f25d04-663d-4fe6-b54a-c09c15951519','daily cleaning','Pembersihan rutin harian seperti menyapu, mengepel, dan membersihkan permukaan.','7d2dd61f-c504-4884-ab69-c6721f7778be'),
	('114d73a8-febd-47d4-a2bd-1520554fa012','cuci kasur','Pembersihan mendalam kasur untuk menghilangkan debu dan kotoran.','ac887a45-11ee-4f05-91f8-73f099220bda'),
	('3b256ee2-cfce-46b7-8d5f-146826e738c9','Isi Freon','Pengisian ulang Freon pada AC agar pendinginannya optimal.','71045063-cac5-4ac7-b3ec-a378a88846eb'),
	('0d3851de-fa0f-4771-ac39-b5232f0cd375','full massage','Pijat tubuh penuh untuk relaksasi dan mengurangi stres.','9606390d-a17e-486f-9a11-15c0eb3b1e05'),
	('ec04feca-cc0c-4f5b-b2af-2b56ba1c9bc0','cuci rambut','Cuci rambut dan pijat kulit kepala untuk kesegaran.','83e6c931-8f65-4b5a-98b8-f0de5034fbbe'),
	('65f45496-2866-4afd-91c0-1ee18a86472c','setrika','Penyetrikaan pakaian dan kain untuk menghilangkan kerutan.','7d2dd61f-c504-4884-ab69-c6721f7778be'),
	('dfd11c08-ee8d-445e-9c2f-487b666e84e5','cuci sofa','Pembersihan mendalam sofa untuk menghilangkan kotoran dan noda.','ac887a45-11ee-4f05-91f8-73f099220bda'),
	('e0a2b7b3-65d4-4d44-a4f0-cc1790e0e386','service umum','Perawatan rutin AC, termasuk pembersihan dan pemeriksaan.','71045063-cac5-4ac7-b3ec-a378a88846eb'),
	('37823a83-0e61-4171-bf33-bfd7de7281b3','feet massage','Pijat kaki untuk meredakan ketegangan dan meningkatkan sirkulasi.','9606390d-a17e-486f-9a11-15c0eb3b1e05'),
	('0d806cf5-db7b-4c6b-a1af-454d6d002088','mewarnai rambut','Pewarnaan rambut untuk perubahan warna sesuai keinginan','83e6c931-8f65-4b5a-98b8-f0de5034fbbe');

INSERT INTO SESI_LAYANAN VALUES ('a7f25d04-663d-4fe6-b54a-c09c15951519',1,65000),
	('a7f25d04-663d-4fe6-b54a-c09c15951519',2,110000),
	('a7f25d04-663d-4fe6-b54a-c09c15951519',3,150000),
	('114d73a8-febd-47d4-a2bd-1520554fa012',1,50000),
	('114d73a8-febd-47d4-a2bd-1520554fa012',2,90000),
	('114d73a8-febd-47d4-a2bd-1520554fa012',3,120000),
	('3b256ee2-cfce-46b7-8d5f-146826e738c9',1,70000),
	('3b256ee2-cfce-46b7-8d5f-146826e738c9',2,130000),
	('3b256ee2-cfce-46b7-8d5f-146826e738c9',3,180000),
	('0d3851de-fa0f-4771-ac39-b5232f0cd375',1,85000),
	('0d3851de-fa0f-4771-ac39-b5232f0cd375',2,160000),
	('0d3851de-fa0f-4771-ac39-b5232f0cd375',3,225000),
	('ec04feca-cc0c-4f5b-b2af-2b56ba1c9bc0',1,105000),
	('ec04feca-cc0c-4f5b-b2af-2b56ba1c9bc0',2,180000),
	('ec04feca-cc0c-4f5b-b2af-2b56ba1c9bc0',3,240000),
	('65f45496-2866-4afd-91c0-1ee18a86472c',1,30000),
	('65f45496-2866-4afd-91c0-1ee18a86472c',2,50000),
	('65f45496-2866-4afd-91c0-1ee18a86472c',3,65000),
	('dfd11c08-ee8d-445e-9c2f-487b666e84e5',1,175000),
	('dfd11c08-ee8d-445e-9c2f-487b666e84e5',2,300000),
	('dfd11c08-ee8d-445e-9c2f-487b666e84e5',3,425000),
	('e0a2b7b3-65d4-4d44-a4f0-cc1790e0e386',1,75000),
	('e0a2b7b3-65d4-4d44-a4f0-cc1790e0e386',2,135000),
	('e0a2b7b3-65d4-4d44-a4f0-cc1790e0e386',3,190000),
	('37823a83-0e61-4171-bf33-bfd7de7281b3',1,60000),
	('37823a83-0e61-4171-bf33-bfd7de7281b3',2,100000),
	('37823a83-0e61-4171-bf33-bfd7de7281b3',3,150000),
	('0d806cf5-db7b-4c6b-a1af-454d6d002088',1,150000),
	('0d806cf5-db7b-4c6b-a1af-454d6d002088',2,250000),
	('0d806cf5-db7b-4c6b-a1af-454d6d002088',3,350000);

INSERT INTO DISKON VALUES ('SPESIALRUMAH2024',25000,100000),
	('BERSIHHEMAT50',50000,200000),
	('JASARUMAH30',30000,85000),
	('GRATISJAMKERJA',10000,50000),
	('PEMBANTUCERIA45',45000,135000),
	('KUPONSEGARRUMAH20',20000,65000),
	('LAYANANSPESIAL15',15000,45000),
	('POTONGANJASARUMAH10',10000,0),
	('VOUCHERPEMBANTU25',25000,50000),
	('PROMOCLEANINGMURAH',40000,100000),
	('CLEANHOUSE2024',20000,85000),
	('SUPERBERSIH50',50000,250000),
	('FLASHCLEAN30',30000,150000),
	('JASAKILATONLINE',15000,95000),
	('GRATISJAMKERJAKU',5000,0),
	('PROMORUMAHSPESIAL',75000,300000),
	('LAYANANHARIINI',15000,0),
	('EXTRACLEANING20',20000,90000),
	('COBAJASAKU',10000,80000),
	('JASARUMAHHEMAT45',45000,175000);

INSERT INTO VOUCHER VALUES ('SPESIALRUMAH2024',15,5,50000),
	('BERSIHHEMAT50',30,5,100000),
	('JASARUMAH30',7,2,20000),
	('GRATISJAMKERJA',60,20,75000),
	('PEMBANTUCERIA45',21,10,150000),
	('KUPONSEGARRUMAH20',30,15,100000),
	('LAYANANSPESIAL15',16,8,40000),
	('POTONGANJASARUMAH10',90,25,100000),
	('VOUCHERPEMBANTU25',17,10,125000),
	('PROMOCLEANINGMURAH',10,15,100000);

INSERT INTO PROMO VALUES ('CLEANHOUSE2024','2024-10-18 00:00:00'),
	('SUPERBERSIH50','2024-11-02 00:00:00'),
	('FLASHCLEAN30','2024-11-15 00:00:00'),
	('JASAKILATONLINE','2024-11-27 00:00:00'),
	('GRATISJAMKERJAKU','2024-12-05 00:00:00'),
	('PROMORUMAHSPESIAL','2024-12-19 00:00:00'),
	('LAYANANHARIINI','2025-01-08 00:00:00'),
	('EXTRACLEANING20','2025-02-14 00:00:00'),
	('COBAJASAKU','2025-03-22 00:00:00'),
	('JASARUMAHHEMAT45','2025-04-30 00:00:00');

INSERT INTO METODE_BAYAR VALUES ('7a1046fa-5dc0-49ad-bd0e-60ada3e239fe','MyPay'),
	('825e2f98-8eff-4d00-8aff-1d56c0fffd14','GoPay'),
	('2b85237a-ccae-4dae-a275-e8d1695c4081','Ovo'),
	('0446a54f-09ea-4bc1-8a17-78c03e9cdea1','Virtual Account BCA'),
	('b64b3991-6d23-4606-995a-4d6f59c31a92','Virtual Account BNI'),
	('c5930fe9-28e3-469a-b715-072b9cf79207','Virtual Account Mandiri');

INSERT INTO TR_PEMBELIAN_VOUCHER VALUES ('0d9e50bb-4799-4738-9cac-b760032856f8','2024-04-03 00:00:00','2024-04-18 00:00:00',4,'8192ca83-c52d-4350-8fa5-64b09cfc96b5','SPESIALRUMAH2024','7a1046fa-5dc0-49ad-bd0e-60ada3e239fe'),
	('b0477805-cdfd-49dc-b49b-4579d7d18a58','2024-02-27 00:00:00','2024-03-28 00:00:00',5,'73215f43-e03b-45be-8808-5d1c48a86b17','BERSIHHEMAT50','825e2f98-8eff-4d00-8aff-1d56c0fffd14'),
	('dd65e64c-1854-4d23-b778-f877986f5beb','2024-03-27 00:00:00','2024-04-03 00:00:00',2,'1dbaa406-59e3-40b2-bff2-2e6cbf22d690','JASARUMAH30','2b85237a-ccae-4dae-a275-e8d1695c4081'),
	('16f39284-1c73-46a9-b002-e9bf0cd4ee0a','2024-05-24 00:00:00','2024-07-23 00:00:00',10,'53ce366d-1b6b-4570-a75b-9af57bf3da57','GRATISJAMKERJA','0446a54f-09ea-4bc1-8a17-78c03e9cdea1'),
	('dc6124ef-8b7d-4d9f-b610-0071d319bdcb','2024-08-29 00:00:00','2024-09-19 00:00:00',7,'96b3c2b0-9a2c-4e4f-8fef-21043d66b421','PEMBANTUCERIA45','b64b3991-6d23-4606-995a-4d6f59c31a92'),
	('da6c8e27-91ce-494b-b799-7be5164f630c','2024-10-02 00:00:00','2024-11-01 00:00:00',3,'8192ca83-c52d-4350-8fa5-64b09cfc96b5','KUPONSEGARRUMAH20','c5930fe9-28e3-469a-b715-072b9cf79207'),
	('aae41eab-cf9b-4f78-b8c6-489940c9a26c','2024-05-03 00:00:00','2024-05-19 00:00:00',6,'1dbaa406-59e3-40b2-bff2-2e6cbf22d690','LAYANANSPESIAL15','7a1046fa-5dc0-49ad-bd0e-60ada3e239fe'),
	('13daa6bb-3452-4959-8ad6-aae35adbb0fb','2024-02-07 00:00:00','2024-05-07 00:00:00',18,'73215f43-e03b-45be-8808-5d1c48a86b17','POTONGANJASARUMAH10','825e2f98-8eff-4d00-8aff-1d56c0fffd14'),
	('0b1041f3-5cde-434b-9cd7-667c5bdeeb9c','2024-04-08 00:00:00','2024-04-25 00:00:00',8,'73215f43-e03b-45be-8808-5d1c48a86b17','VOUCHERPEMBANTU25','2b85237a-ccae-4dae-a275-e8d1695c4081'),
	('3ba9bb16-3b08-4713-a559-da1ee76e563a','2024-07-05 00:00:00','2024-07-15 00:00:00',5,'8192ca83-c52d-4350-8fa5-64b09cfc96b5','PROMOCLEANINGMURAH','0446a54f-09ea-4bc1-8a17-78c03e9cdea1'),
	('c7fe81ef-6ad9-4ad0-a99c-ea879709204a','2024-04-28 00:00:00','2024-05-13 00:00:00',3,'53ce366d-1b6b-4570-a75b-9af57bf3da57','SPESIALRUMAH2024','b64b3991-6d23-4606-995a-4d6f59c31a92'),
	('b3538ce3-b741-4553-9452-283cbc9c9302','2024-01-27 00:00:00','2024-02-26 00:00:00',4,'1dbaa406-59e3-40b2-bff2-2e6cbf22d690','BERSIHHEMAT50','c5930fe9-28e3-469a-b715-072b9cf79207'),
	('f692718a-8f52-4ffc-a3a8-d891f587221c','2024-02-02 00:00:00','2024-02-09 00:00:00',2,'8192ca83-c52d-4350-8fa5-64b09cfc96b5','JASARUMAH30','7a1046fa-5dc0-49ad-bd0e-60ada3e239fe'),
	('5f9b46c8-4b83-481a-98a8-7f902a90bdc8','2024-05-20 00:00:00','2024-07-19 00:00:00',11,'73215f43-e03b-45be-8808-5d1c48a86b17','GRATISJAMKERJA','825e2f98-8eff-4d00-8aff-1d56c0fffd14'),
	('bd0a4242-cd28-44ba-89d3-a18509f5810e','2024-02-06 00:00:00','2024-02-27 00:00:00',3,'73215f43-e03b-45be-8808-5d1c48a86b17','PEMBANTUCERIA45','2b85237a-ccae-4dae-a275-e8d1695c4081'),
	('db95e017-4245-41df-99aa-c51a1cb072a5','2024-05-08 00:00:00','2024-06-07 00:00:00',1,'8192ca83-c52d-4350-8fa5-64b09cfc96b5','KUPONSEGARRUMAH20','0446a54f-09ea-4bc1-8a17-78c03e9cdea1'),
	('9bc54d88-c702-424c-a010-6d4aa01268fd','2024-06-22 00:00:00','2024-07-08 00:00:00',0,'53ce366d-1b6b-4570-a75b-9af57bf3da57','LAYANANSPESIAL15','b64b3991-6d23-4606-995a-4d6f59c31a92'),
	('27b52e3b-ee25-4aff-9268-49e8e7d888e8','2024-03-12 00:00:00','2024-06-10 00:00:00',25,'1dbaa406-59e3-40b2-bff2-2e6cbf22d690','POTONGANJASARUMAH10','c5930fe9-28e3-469a-b715-072b9cf79207');

INSERT INTO TR_PEMESANAN_JASA VALUES ('1f58bc66-d1e7-43bb-890d-c24d5e8805ea','2024-05-09 00:00:00','2024-05-11 00:00:00','2024-05-11 11:30:00',60000,'8192ca83-c52d-4350-8fa5-64b09cfc96b5','df6e4bf7-ad28-4444-aefe-31a4d00c0d7b','114d73a8-febd-47d4-a2bd-1520554fa012',2,'JASARUMAH30','7a1046fa-5dc0-49ad-bd0e-60ada3e239fe'),
	('62495f8a-181f-49e8-a401-8d8c2537081a','2024-04-18 00:00:00','2024-04-20 00:00:00','2024-04-20 15:00:00',70000,'73215f43-e03b-45be-8808-5d1c48a86b17','b81696c4-5dda-45db-b34f-0e1b4676b579','3b256ee2-cfce-46b7-8d5f-146826e738c9',1,NULL,'825e2f98-8eff-4d00-8aff-1d56c0fffd14'),
	('42b7b800-cc28-4b51-a335-65742e892e57','2024-06-18 00:00:00','2024-06-20 00:00:00','2024-06-20 14:45:00',125000,'1dbaa406-59e3-40b2-bff2-2e6cbf22d690','9eecc737-928e-46ab-97c5-b91168b934dc','a7f25d04-663d-4fe6-b54a-c09c15951519',3,'SPESIALRUMAH2024','2b85237a-ccae-4dae-a275-e8d1695c4081'),
	('0bb25ee0-7e8d-4ff3-936c-b25e695e3c6c','2024-01-09 00:00:00','2024-01-11 00:00:00','2024-01-11 09:00:00',20000,'53ce366d-1b6b-4570-a75b-9af57bf3da57','1b835a8e-523c-4eac-9839-e867bdf07ba2','65f45496-2866-4afd-91c0-1ee18a86472c',1,'POTONGANJASARUMAH10','0446a54f-09ea-4bc1-8a17-78c03e9cdea1'),
	('d3a1a05c-3911-4631-957b-0a26c1a0e4b5','2024-06-17 00:00:00','2024-06-19 00:00:00','2024-06-19 14:00:00',150000,'96b3c2b0-9a2c-4e4f-8fef-21043d66b421','60d5d1ec-83b4-497a-a38b-7b56977d6cb0','ec04feca-cc0c-4f5b-b2af-2b56ba1c9bc0',2,'FLASHCLEAN30','b64b3991-6d23-4606-995a-4d6f59c31a92'),
	('321fba6f-6c99-48ca-83d1-56353f776ae5','2024-10-03 00:00:00','2024-10-05 00:00:00','2024-10-05 13:15:00',115000,'8192ca83-c52d-4350-8fa5-64b09cfc96b5','df6e4bf7-ad28-4444-aefe-31a4d00c0d7b','3b256ee2-cfce-46b7-8d5f-146826e738c9',2,'LAYANANHARIINI','c5930fe9-28e3-469a-b715-072b9cf79207'),
	('d724ea61-c76d-49bd-af57-9e1b707ae225','2024-05-18 00:00:00','2024-05-20 00:00:00','2024-05-20 17:15:00',85000,'73215f43-e03b-45be-8808-5d1c48a86b17','b81696c4-5dda-45db-b34f-0e1b4676b579','0d3851de-fa0f-4771-ac39-b5232f0cd375',1,NULL,'7a1046fa-5dc0-49ad-bd0e-60ada3e239fe'),
	('0ac10d87-8bec-41dd-b29e-5c99185fd3f1','2024-02-20 00:00:00','2024-02-22 00:00:00','2024-02-22 10:45:00',85000,'1dbaa406-59e3-40b2-bff2-2e6cbf22d690','9eecc737-928e-46ab-97c5-b91168b934dc','ec04feca-cc0c-4f5b-b2af-2b56ba1c9bc0',1,'CLEANHOUSE2024','825e2f98-8eff-4d00-8aff-1d56c0fffd14'),
	('b7caa108-7e75-4521-ac67-3095d346b3c1','2024-07-17 00:00:00','2024-07-19 00:00:00','2024-07-19 14:45:00',50000,'53ce366d-1b6b-4570-a75b-9af57bf3da57','1b835a8e-523c-4eac-9839-e867bdf07ba2','114d73a8-febd-47d4-a2bd-1520554fa012',1,NULL,'2b85237a-ccae-4dae-a275-e8d1695c4081'),
	('1cda3801-af9d-4b31-8bd7-1a47108398f5','2024-02-25 00:00:00','2024-02-27 00:00:00','2024-02-27 15:00:00',300000,'96b3c2b0-9a2c-4e4f-8fef-21043d66b421','60d5d1ec-83b4-497a-a38b-7b56977d6cb0','0d806cf5-db7b-4c6b-a1af-454d6d002088',3,'SUPERBERSIH50','0446a54f-09ea-4bc1-8a17-78c03e9cdea1'),
	('f874e0f7-3aab-4ec9-ba54-479ecc9bd7bc','2024-03-20 00:00:00','2024-03-22 00:00:00','2024-03-22 09:00:00',375000,'8192ca83-c52d-4350-8fa5-64b09cfc96b5','df6e4bf7-ad28-4444-aefe-31a4d00c0d7b','dfd11c08-ee8d-445e-9c2f-487b666e84e5',3,'SUPERBERSIH50','b64b3991-6d23-4606-995a-4d6f59c31a92'),
	('ded468ce-251a-4834-bb0d-9dd2347ad864','2024-09-18 00:00:00','2024-09-20 00:00:00','2024-09-20 10:00:00',105000,'73215f43-e03b-45be-8808-5d1c48a86b17','b81696c4-5dda-45db-b34f-0e1b4676b579','114d73a8-febd-47d4-a2bd-1520554fa012',3,'JASAKILATONLINE','c5930fe9-28e3-469a-b715-072b9cf79207'),
	('5f1ddc6e-9962-4540-8c1a-d33d5e000348','2024-07-15 00:00:00','2024-07-17 00:00:00','2024-07-17 13:30:00',180000,'1dbaa406-59e3-40b2-bff2-2e6cbf22d690','9eecc737-928e-46ab-97c5-b91168b934dc','3b256ee2-cfce-46b7-8d5f-146826e738c9',3,NULL,'7a1046fa-5dc0-49ad-bd0e-60ada3e239fe'),
	('327c2f7c-c11d-4d1c-a751-7045875ac9aa','2024-03-20 00:00:00','2024-03-22 00:00:00','2024-03-22 15:45:00',110000,'53ce366d-1b6b-4570-a75b-9af57bf3da57','1b835a8e-523c-4eac-9839-e867bdf07ba2','3b256ee2-cfce-46b7-8d5f-146826e738c9',2,'EXTRACLEANING20','825e2f98-8eff-4d00-8aff-1d56c0fffd14'),
	('64891375-5a3d-4386-a7a4-36adf3f742ec','2024-04-12 00:00:00','2024-04-14 00:00:00','2024-04-14 16:15:00',50000,'96b3c2b0-9a2c-4e4f-8fef-21043d66b421','60d5d1ec-83b4-497a-a38b-7b56977d6cb0','114d73a8-febd-47d4-a2bd-1520554fa012',1,NULL,'2b85237a-ccae-4dae-a275-e8d1695c4081'),
	('2a63adce-8ad3-4efc-a123-39a480717af6','2024-01-13 00:00:00','2024-01-15 00:00:00','2024-01-15 12:00:00',50000,'8192ca83-c52d-4350-8fa5-64b09cfc96b5','df6e4bf7-ad28-4444-aefe-31a4d00c0d7b','65f45496-2866-4afd-91c0-1ee18a86472c',2,NULL,'0446a54f-09ea-4bc1-8a17-78c03e9cdea1'),
	('c691183d-caaa-4eb3-a60f-2b45af08bf16','2024-01-03 00:00:00','2024-01-05 00:00:00','2024-01-05 09:30:00',105000,'73215f43-e03b-45be-8808-5d1c48a86b17','b81696c4-5dda-45db-b34f-0e1b4676b579','37823a83-0e61-4171-bf33-bfd7de7281b3',3,'PEMBANTUCERIA45','b64b3991-6d23-4606-995a-4d6f59c31a92'),
	('62aae959-adc7-428e-b13d-c9db30bea6c2','2024-04-24 00:00:00','2024-04-26','2024-04-26 14:30:00',190000,'1dbaa406-59e3-40b2-bff2-2e6cbf22d690','9eecc737-928e-46ab-97c5-b91168b934dc','ec04feca-cc0c-4f5b-b2af-2b56ba1c9bc0',3,'BERSIHHEMAT50','c5930fe9-28e3-469a-b715-072b9cf79207'),
	('e509bc0b-825c-4802-8b24-e8ffced94f93','2024-04-04 00:00:00','2024-04-06','2024-04-06 16:00:00',145000,'53ce366d-1b6b-4570-a75b-9af57bf3da57','1b835a8e-523c-4eac-9839-e867bdf07ba2','e0a2b7b3-65d4-4d44-a4f0-cc1790e0e386',3,'JASARUMAHHEMAT45','7a1046fa-5dc0-49ad-bd0e-60ada3e239fe'),
	('2a35ceb2-e0a1-47c0-a7ac-c487ed22fc91','2024-06-20 00:00:00','2024-06-22','2024-06-22 14:30:00',60000,'96b3c2b0-9a2c-4e4f-8fef-21043d66b421','60d5d1ec-83b4-497a-a38b-7b56977d6cb0','37823a83-0e61-4171-bf33-bfd7de7281b3',1,NULL,'825e2f98-8eff-4d00-8aff-1d56c0fffd14'),
	('4cf67fe6-1f55-4824-99f3-7c937af71e03','2024-06-18 00:00:00','2024-06-20 00:00:00','2024-06-20 14:15:00',75000,'8192ca83-c52d-4350-8fa5-64b09cfc96b5','df6e4bf7-ad28-4444-aefe-31a4d00c0d7b','114d73a8-febd-47d4-a2bd-1520554fa012',2,'LAYANANSPESIAL15','2b85237a-ccae-4dae-a275-e8d1695c4081'),
	('c97613a9-51fe-4fdd-bdd6-ce25c536d686','2024-08-30 00:00:00','2024-09-01 00:00:00','2024-09-01 16:30:00',350000,'73215f43-e03b-45be-8808-5d1c48a86b17','b81696c4-5dda-45db-b34f-0e1b4676b579','0d806cf5-db7b-4c6b-a1af-454d6d002088',3,NULL,'0446a54f-09ea-4bc1-8a17-78c03e9cdea1'),
	('cd4c29ad-ce2c-4b8e-a2f9-a99f17d7f8ef','2024-06-16 00:00:00','2024-06-18 00:00:00','2024-06-18 09:00:00',45000,'1dbaa406-59e3-40b2-bff2-2e6cbf22d690','9eecc737-928e-46ab-97c5-b91168b934dc','65f45496-2866-4afd-91c0-1ee18a86472c',3,'KUPONSEGARRUMAH20','b64b3991-6d23-4606-995a-4d6f59c31a92'),
	('124eea7c-6c45-4500-a76a-2f829c1f9a90','2024-10-05 00:00:00','2024-10-07 00:00:00','2024-10-07 13:00:00',70000,'53ce366d-1b6b-4570-a75b-9af57bf3da57','1b835a8e-523c-4eac-9839-e867bdf07ba2','3b256ee2-cfce-46b7-8d5f-146826e738c9',1,NULL,'c5930fe9-28e3-469a-b715-072b9cf79207'),
	('8a2a61ac-7029-4646-bb4f-416b5d475338','2024-10-09 00:00:00','2024-10-11 00:00:00','2024-10-11 17:30:00',115000,'96b3c2b0-9a2c-4e4f-8fef-21043d66b421','60d5d1ec-83b4-497a-a38b-7b56977d6cb0','e0a2b7b3-65d4-4d44-a4f0-cc1790e0e386',2,'EXTRACLEANING20','2b85237a-ccae-4dae-a275-e8d1695c4081');

INSERT INTO STATUS_PESANAN VALUES ('a35b71a4-cb92-4131-a8ed-ec504de752cb','Menunggu Pembayaran'),
	('9b0afa62-7c46-4266-9269-2a4268522619','Mencari Pekerja Terdekat'),
	('26dcdf4b-1d45-491f-9056-32d146c1808c','Menunggu Pekerja Berangkat'),
	('40a11d44-c5de-4f5b-8420-fd23b1b51367','Pekerja tiba di lokasi'),
	('b53eeba3-4d5c-4a46-991f-73df7af49a58','Pelayanan jasa sedang dilakukan'),
	('23a648e2-bc41-4cec-aa07-3a2bec8214e3','Pesanan selesai'),
	('b3e8f8d4-8660-461c-ba70-ef8528d6ee1c','Pesanan dibatalkan');


INSERT INTO TR_PEMESANAN_STATUS VALUES ('1f58bc66-d1e7-43bb-890d-c24d5e8805ea','a35b71a4-cb92-4131-a8ed-ec504de752cb','2024-05-09 11:30:00'),
	('62495f8a-181f-49e8-a401-8d8c2537081a','40a11d44-c5de-4f5b-8420-fd23b1b51367','2024-04-20 14:55:00'),
	('42b7b800-cc28-4b51-a335-65742e892e57','b53eeba3-4d5c-4a46-991f-73df7af49a58','2024-06-20 14:45:00'),
	('0bb25ee0-7e8d-4ff3-936c-b25e695e3c6c','26dcdf4b-1d45-491f-9056-32d146c1808c','2024-01-11 08:30:00'),
	('d3a1a05c-3911-4631-957b-0a26c1a0e4b5','b3e8f8d4-8660-461c-ba70-ef8528d6ee1c','2024-06-18 14:00:00'),
	('321fba6f-6c99-48ca-83d1-56353f776ae5','26dcdf4b-1d45-491f-9056-32d146c1808c','2024-10-05 12:45:00'),
	('d724ea61-c76d-49bd-af57-9e1b707ae225','b53eeba3-4d5c-4a46-991f-73df7af49a58','2024-05-20 17:15:00'),
	('0ac10d87-8bec-41dd-b29e-5c99185fd3f1','9b0afa62-7c46-4266-9269-2a4268522619','2024-02-22 09:45:00'),
	('b7caa108-7e75-4521-ac67-3095d346b3c1','9b0afa62-7c46-4266-9269-2a4268522619','2024-07-19 13:45:00'),
	('1cda3801-af9d-4b31-8bd7-1a47108398f5','a35b71a4-cb92-4131-a8ed-ec504de752cb','2024-02-25 15:00:00'),
	('f874e0f7-3aab-4ec9-ba54-479ecc9bd7bc','b3e8f8d4-8660-461c-ba70-ef8528d6ee1c','2024-03-21 09:00:00'),
	('ded468ce-251a-4834-bb0d-9dd2347ad864','b53eeba3-4d5c-4a46-991f-73df7af49a58','2024-09-20 10:00:00'),
	('5f1ddc6e-9962-4540-8c1a-d33d5e000348','a35b71a4-cb92-4131-a8ed-ec504de752cb','2024-07-15 13:30:00'),
	('327c2f7c-c11d-4d1c-a751-7045875ac9aa','b53eeba3-4d5c-4a46-991f-73df7af49a58','2024-03-22 15:45:00'),
	('64891375-5a3d-4386-a7a4-36adf3f742ec','b3e8f8d4-8660-461c-ba70-ef8528d6ee1c','2024-04-12 19:15:00'),
	('2a63adce-8ad3-4efc-a123-39a480717af6','a35b71a4-cb92-4131-a8ed-ec504de752cb','2024-01-13 15:00:00'),
	('c691183d-caaa-4eb3-a60f-2b45af08bf16','b53eeba3-4d5c-4a46-991f-73df7af49a58','2024-01-05 09:30:00'),
	('62aae959-adc7-428e-b13d-c9db30bea6c2','40a11d44-c5de-4f5b-8420-fd23b1b51367','2024-04-26 14:25:00'),
	('e509bc0b-825c-4802-8b24-e8ffced94f93','b53eeba3-4d5c-4a46-991f-73df7af49a58','2024-04-06 16:00:00'),
	('2a35ceb2-e0a1-47c0-a7ac-c487ed22fc91','b53eeba3-4d5c-4a46-991f-73df7af49a58','2024-06-22 14:30:00'),
	('4cf67fe6-1f55-4824-99f3-7c937af71e03','40a11d44-c5de-4f5b-8420-fd23b1b51367','2024-06-20 14:13:00'),
	('c97613a9-51fe-4fdd-bdd6-ce25c536d686','b53eeba3-4d5c-4a46-991f-73df7af49a58','2024-09-01 16:30:00'),
	('cd4c29ad-ce2c-4b8e-a2f9-a99f17d7f8ef','23a648e2-bc41-4cec-aa07-3a2bec8214e3','2024-06-18 12:00:00'),
	('124eea7c-6c45-4500-a76a-2f829c1f9a90','a35b71a4-cb92-4131-a8ed-ec504de752cb','2024-10-05 13:00:00'),
	('8a2a61ac-7029-4646-bb4f-416b5d475338','b3e8f8d4-8660-461c-ba70-ef8528d6ee1c','2024-10-10 17:30:00'),
	('1f58bc66-d1e7-43bb-890d-c24d5e8805ea','23a648e2-bc41-4cec-aa07-3a2bec8214e3','2024-05-11 13:30:00'),
	('62495f8a-181f-49e8-a401-8d8c2537081a','b53eeba3-4d5c-4a46-991f-73df7af49a58','2024-04-20 15:00:00'),
	('42b7b800-cc28-4b51-a335-65742e892e57','40a11d44-c5de-4f5b-8420-fd23b1b51367','2024-06-20 14:40:00'),
	('0bb25ee0-7e8d-4ff3-936c-b25e695e3c6c','23a648e2-bc41-4cec-aa07-3a2bec8214e3','2024-01-11 10:00:00'),
	('d3a1a05c-3911-4631-957b-0a26c1a0e4b5','23a648e2-bc41-4cec-aa07-3a2bec8214e3','2024-06-19 16:00:00'),
	('321fba6f-6c99-48ca-83d1-56353f776ae5','b53eeba3-4d5c-4a46-991f-73df7af49a58','2024-10-05 13:15:00'),
	('d724ea61-c76d-49bd-af57-9e1b707ae225','23a648e2-bc41-4cec-aa07-3a2bec8214e3','2024-05-20 18:15:00'),
	('0ac10d87-8bec-41dd-b29e-5c99185fd3f1','23a648e2-bc41-4cec-aa07-3a2bec8214e3','2024-02-22 11:45:00'),
	('b7caa108-7e75-4521-ac67-3095d346b3c1','b53eeba3-4d5c-4a46-991f-73df7af49a58','2024-07-19 14:45:00'),
	('1cda3801-af9d-4b31-8bd7-1a47108398f5','23a648e2-bc41-4cec-aa07-3a2bec8214e3','2024-02-27 18:00:00');


INSERT INTO TESTIMONI VALUES ('1f58bc66-d1e7-43bb-890d-c24d5e8805ea','2024-05-11 00:00:00','Layanannya cepat dan memuaskan!',5),
	('62495f8a-181f-49e8-a401-8d8c2537081a','2024-04-20 00:00:00','Sangat puas dengan hasilnya!',5),
	('42b7b800-cc28-4b51-a335-65742e892e57','2024-06-20 00:00:00','Timnya profesional dan rapi.',5),
	('0bb25ee0-7e8d-4ff3-936c-b25e695e3c6c','2024-01-11 00:00:00','Pekerjaan selesai dengan baik dan cepat.',4),
	('62aae959-adc7-428e-b13d-c9db30bea6c2','2024-04-26 00:00:00','Hasilnya bersih dan memuaskan!',4),
	('321fba6f-6c99-48ca-83d1-56353f776ae5','2024-10-05 00:00:00','Pelayanannya ramah dan efisien.',5),
	('d724ea61-c76d-49bd-af57-9e1b707ae225','2024-05-20 00:00:00','Rumah jadi bersih sekali!',4),
	('0ac10d87-8bec-41dd-b29e-5c99185fd3f1','2024-02-22 00:00:00','Harga terjangkau, hasil memuaskan.',5),
	('b7caa108-7e75-4521-ac67-3095d346b3c1','2024-07-19 00:00:00','Layanannya sangat membantu!',4),
	('1cda3801-af9d-4b31-8bd7-1a47108398f5','2024-02-27 00:00:00','Pekerjanya cepat dan handal.',5),
	('e509bc0b-825c-4802-8b24-e8ffced94f93','2024-04-06 00:00:00','Sangat senang dengan hasilnya!',4),
	('ded468ce-251a-4834-bb0d-9dd2347ad864','2024-09-20 00:00:00','Pekerjaan rapi dan cepat selesai.',5),
	('5f1ddc6e-9962-4540-8c1a-d33d5e000348','2024-07-17 00:00:00','Sangat memuaskan, rumah jadi rapi.',5),
	('327c2f7c-c11d-4d1c-a751-7045875ac9aa','2024-03-22 00:00:00','Sesuai harapan, sangat rapi!',5),
	('2a35ceb2-e0a1-47c0-a7ac-c487ed22fc91','2024-06-22 00:00:00','Pekerjaannya cepat dan tepat.',4),
	('2a63adce-8ad3-4efc-a123-39a480717af6','2024-01-15 00:00:00','Lingkungan jadi lebih indah!',5),
	('c691183d-caaa-4eb3-a60f-2b45af08bf16','2024-01-05 00:00:00','Pasti akan pesan lagi, sangat puas!',5);