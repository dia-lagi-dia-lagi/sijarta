SELECT * FROM DISKON NATURAL JOIN VOUCHER;

SELECT * FROM PROMO;

SELECT * FROM METODE_BAYAR;

DROP TRIGGER IF EXISTS trg_validate_voucher_buy ON TR_PEMBELIAN_VOUCHER;

DROP TRIGGER IF EXISTS trg_update_voucher_buy ON TR_PEMBELIAN_VOUCHER;

CREATE OR REPLACE FUNCTION validate_voucher_buy()
RETURNS trigger AS
$$
DECLARE
    voucher_harga NUMERIC; -- Adjust type as per the `harga` column
    user_saldo NUMERIC;    -- Adjust type as per the `saldomypay` column
    mypay_metode_id UUID;   -- Adjust type as per `id_metode_bayar`
BEGIN
    -- Check if the voucher exists and fetch its price
    SELECT harga
    INTO voucher_harga
    FROM VOUCHER
    WHERE kode = NEW.id_voucher;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Voucher tidak ada dengan kode: %', NEW.id_voucher;
    END IF;

    -- Fetch the ID for the 'MyPay' payment method
    SELECT id_metode_bayar
    INTO mypay_metode_id
    FROM METODE_BAYAR
    WHERE nama = 'MyPay';

    -- If 'MyPay' is used, validate the user's saldo
    IF NEW.id_metode_bayar = mypay_metode_id THEN
        SELECT saldomypay
        INTO user_saldo
        FROM USERS
        WHERE id_user = NEW.id_pelanggan;

        IF voucher_harga > user_saldo THEN
            RAISE EXCEPTION 'Saldo MyPay tidak mencukupi untuk membayar voucher tersebut';
        END IF;
    END IF;

    -- If all checks pass, allow the operation
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

INSERT INTO users (id_user, nama, jenis_kelamin, no_hp, pwd, tgl_lahir, alamat, saldomypay)
VALUES (gen_random_uuid(), 'John Doe', 'L', '08123456789', 'password123', '1990-01-01', '123 Main St', 0);

'8750a667-8542-4e7f-aa97-f6ecbeddf14e'

INSERT INTO TR_PEMBELIAN_VOUCHER VALUES ('b0a3d6e1-ab36-4ad4-80e8-cee9fe64d60e','2024-04-03 00:00:00',
NULL,4,'8750a667-8542-4e7f-aa97-f6ecbeddf14e','SPESIALRUMAH2024',
'7a1046fa-5dc0-49ad-bd0e-60ada3e239fe');

UPDATE USERS SET saldomypay = 100000 WHERE id_user ='8750a667-8542-4e7f-aa97-f6ecbeddf14e';

DELETE FROM TR_PEMBELIAN_VOUCHER WHERE id_tr_pembelian_voucher = 'b0a3d6e1-ab36-4ad4-80e8-cee9fe64d60e';


CREATE TRIGGER trg_validate_voucher_buy
BEFORE INSERT OR UPDATE ON TR_PEMBELIAN_VOUCHER
FOR EACH ROW 
EXECUTE FUNCTION validate_voucher_buy();

CREATE OR REPLACE FUNCTION update_voucher_buy()
RETURNS trigger AS
$$
DECLARE
    voucher_harga NUMERIC; -- Adjust type as per the `harga` column
     mypay_metode_id UUID;
BEGIN

    SELECT harga
    INTO voucher_harga
    FROM VOUCHER
    WHERE kode = NEW.id_voucher;

    SELECT id_metode_bayar
    INTO mypay_metode_id
    FROM METODE_BAYAR
    WHERE nama = 'MyPay';

   IF NEW.id_metode_bayar = mypay_metode_id THEN

    UPDATE USERS u SET saldomypay=saldomypay - voucher_harga 
    WHERE NEW.id_pelanggan = u.id_user;

    END IF;



    RETURN NULL;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER trg_update_voucher_buy
AFTER INSERT ON TR_PEMBELIAN_VOUCHER
FOR EACH ROW 
EXECUTE FUNCTION update_voucher_buy();

CREATE TRIGGER trg_validate_voucher_buy
BEFORE INSERT OR UPDATE ON TR_PEMBELIAN_VOUCHER
FOR EACH ROW 
EXECUTE FUNCTION validate_voucher_buy();



CREATE OR REPLACE FUNCTION insert_tglakhir_voucher_buy()
RETURNS trigger AS
$$
DECLARE
    jml_hari_voucher INTEGER; 
BEGIN

    -- Check if the voucher exists
    IF EXISTS (SELECT 1 FROM VOUCHER WHERE NEW.id_voucher = VOUCHER.kode) THEN

        -- Fetch the validity period of the voucher
        SELECT jml_hari_berlaku INTO jml_hari_voucher
        FROM VOUCHER 
        WHERE NEW.id_voucher = VOUCHER.kode;

        -- Set tgl_akhir if it is NULL
        IF NEW.tgl_akhir IS NULL THEN
            NEW.tgl_akhir := NEW.tgl_awal + jml_hari_voucher;
        END IF;

    ELSE
        -- Raise an exception if the voucher doesn't exist
        RAISE EXCEPTION 'Voucher with kode % does not exist', NEW.id_voucher;
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

-- Create the trigger
CREATE TRIGGER trg_insert_tglakhir_voucher_buy
BEFORE INSERT ON TR_PEMBELIAN_VOUCHER
FOR EACH ROW 
EXECUTE FUNCTION insert_tglakhir_voucher_buy();

INSERT INTO TR_PEMBELIAN_VOUCHER VALUES ('b0a3d6e1-ab36-4ad4-80e8-cee9fe64d60e','2024-04-03 00:00:00',
NULL,4,'73215f43-e03b-45be-8808-5d1c48a86b17','SPESIALRUMAH2024',
'c5930fe9-28e3-469a-b715-072b9cf79207');



CREATE OR REPLACE FUNCTION insert_trmypay_voucher_buy()
RETURNS trigger AS
$$
DECLARE
    bayarvoucher_mypay_id UUID; 
    mypay_metode_id UUID;
    voucher_harga NUMERIC;
BEGIN
    -- Fetch MyPay method ID
    SELECT id_metode_bayar
    INTO mypay_metode_id
    FROM METODE_BAYAR
    WHERE nama = 'MyPay';

    -- Check if the method ID matches
    IF NEW.id_metode_bayar = mypay_metode_id THEN
        -- Fetch category ID for 'Membayar Voucher'
        SELECT id_kategori_tr_mypay
        INTO bayarvoucher_mypay_id
        FROM KATEGORI_TR_MYPAY
        WHERE nama = 'Membayar Voucher';

        -- Fetch the voucher price
        SELECT harga
        INTO voucher_harga
        FROM VOUCHER
        WHERE kode = NEW.id_voucher;

        -- Insert into TR_MYPAY
        INSERT INTO TR_MYPAY VALUES (
            gen_random_uuid(), 
            NEW.id_pelanggan, 
            NEW.tgl_awal, 
            voucher_harga, 
            bayarvoucher_mypay_id
        );
    END IF;

    -- Return the new row
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

-- Create trigger
CREATE TRIGGER trg_insert_trmypay_voucher_buy
AFTER INSERT ON TR_PEMBELIAN_VOUCHER
FOR EACH ROW 
EXECUTE FUNCTION insert_trmypay_voucher_buy();

DROP TRIGGER IF EXISTS trg_insert_trmypay_voucher_buy ON TR_PEMBELIAN_VOUCHER;

INSERT INTO KATEGORI_TR_MYPAY
VALUES (gen_random_uuid(), 'Membayar Voucher');





DROP TRIGGER IF EXISTS trg_validate_discount_usage ON TR_PEMESANAN_JASA;




CREATE OR REPLACE FUNCTION validate_voucher_usage()
RETURNS trigger AS
$$
BEGIN
    -- Check if the voucher exists in the VOUCHER table
    IF EXISTS (SELECT 1 FROM VOUCHER v WHERE NEW.id_diskon = v.kode) THEN
        
        -- Check if the voucher was purchased
        IF EXISTS (SELECT 1 FROM TR_PEMBELIAN_VOUCHER trv WHERE NEW.id_diskon = trv.id_voucher) THEN
            
            -- Validate voucher usage limit
            IF NOT EXISTS (
                SELECT 1 
                FROM TR_PEMBELIAN_VOUCHER trv
                WHERE NEW.id_pelanggan = trv.id_pelanggan 
                  AND NEW.id_diskon = trv.id_voucher
                  AND trv.telah_digunakan < (
                      SELECT kuota_penggunaan 
                      FROM VOUCHER v 
                      WHERE v.kode = NEW.id_diskon
                  )
            ) THEN
                RAISE EXCEPTION 'Pemakaian Voucher telah melebihi batas pemakaian';
            END IF;
            
            -- Validate voucher expiration date
            IF NOT EXISTS (
                SELECT 1 
                FROM TR_PEMBELIAN_VOUCHER trv
                WHERE NEW.id_pelanggan = trv.id_pelanggan 
                  AND NEW.id_diskon = trv.id_voucher
                  AND NEW.tgl_pemesanan < (
                      SELECT tgl_akhir 
                      FROM VOUCHER v 
                      WHERE v.kode = NEW.id_diskon
                  )
            ) THEN
                RAISE EXCEPTION 'Batas pemakaian voucher telah lewat.';
            END IF;

        ELSE
            RAISE EXCEPTION 'Voucher tidak pernah dibeli dengan kode: %', NEW.id_diskon;
        END IF;
    END IF;

    RETURN NEW; -- Allow the operation if no conditions fail
END;
$$
LANGUAGE plpgsql;

-- Create a trigger to validate voucher usage before insert or update
CREATE TRIGGER trg_validate_voucher_usage
BEFORE INSERT OR UPDATE ON TR_PEMESANAN_JASA
FOR EACH ROW 
EXECUTE FUNCTION validate_voucher_usage();



CREATE OR REPLACE FUNCTION update_voucher_usage()
RETURNS trigger AS
$$
BEGIN
    -- Increment kuota_penggunaan in TR_PEMBELIAN_VOUCHER if conditions match
    UPDATE TR_PEMBELIAN_VOUCHER trv
    SET telah_digunakan = telah_digunakan + 1
    WHERE trv.id_tr_pembelian_voucher = (
        SELECT trv_inner.id_tr_pembelian_voucher
        FROM TR_PEMBELIAN_VOUCHER trv_inner
        JOIN VOUCHER v ON v.kode = trv_inner.id_voucher
        WHERE NEW.id_pelanggan = trv_inner.id_pelanggan
          AND NEW.id_diskon = trv_inner.id_voucher
          AND trv_inner.telah_digunakan < v.kuota_penggunaan
          AND NEW.tgl_pemesanan < trv.tgl_akhir
        ORDER BY trv.tgl_awal ASC
        LIMIT 1
        FOR UPDATE
    );

    RETURN NULL; -- After triggers don't modify rows
END;
$$
LANGUAGE plpgsql;

-- Create the trigger
CREATE TRIGGER trg_update_voucher_usage
AFTER INSERT ON TR_PEMESANAN_JASA
FOR EACH ROW
EXECUTE FUNCTION update_voucher_usage();


INSERT INTO TR_PEMESANAN_JASA VALUES ('1f58bc66-d1e7-43bb-890d-c24d5e8805ea',
'2024-03-09 00:00:00','2024-05-11 00:00:00','2024-05-11 11:30:00',60000,'8192ca83-c52d-4350-8fa5-64b09cfc96b5',
'df6e4bf7-ad28-4444-aefe-31a4d00c0d7b','114d73a8-febd-47d4-a2bd-1520554fa012',2,'SPESIALRUMAH2024',
'7a1046fa-5dc0-49ad-bd0e-60ada3e239fe');

INSERT INTO TR_PEMESANAN_JASA VALUES ('1f58bc66-d1e7-43bb-890d-c24d5e8805ea',
'2025-03-09 00:00:00','2024-05-11 00:00:00','2024-05-11 11:30:00',60000,'8192ca83-c52d-4350-8fa5-64b09cfc96b5',
'df6e4bf7-ad28-4444-aefe-31a4d00c0d7b','114d73a8-febd-47d4-a2bd-1520554fa012',2,'SPESIALRUMAH2024',
'7a1046fa-5dc0-49ad-bd0e-60ada3e239fe');


INSERT INTO TR_PEMESANAN_JASA VALUES ('b0a3d6e1-ab36-4ad4-80e8-cee9fe64d60e',
'2024-03-09 00:00:00','2024-05-11 00:00:00','2024-05-11 11:30:00',60000,'8192ca83-c52d-4350-8fa5-64b09cfc96b5',
'df6e4bf7-ad28-4444-aefe-31a4d00c0d7b','114d73a8-febd-47d4-a2bd-1520554fa012',2,'SPESIALRUMAH2024',
'7a1046fa-5dc0-49ad-bd0e-60ada3e239fe');

INSERT INTO TR_PEMESANAN_JASA VALUES ('b0a3d6e1-ab36-4ad4-80e8-cee9fe64d60e',
'2024-03-09 00:00:00','2024-05-11 00:00:00','2024-05-11 11:30:00',60000,'8192ca83-c52d-4350-8fa5-64b09cfc96b5',
'df6e4bf7-ad28-4444-aefe-31a4d00c0d7b','114d73a8-febd-47d4-a2bd-1520554fa012',2,NULL,
'7a1046fa-5dc0-49ad-bd0e-60ada3e239fe');

INSERT INTO TR_PEMESANAN_JASA VALUES ('b0a3d6e1-ab36-4ad4-80e8-cee9fe64d60e',
'2024-03-09 00:00:00','2024-05-11 00:00:00','2024-05-11 11:30:00',60000,'8192ca83-c52d-4350-8fa5-64b09cfc96b5',
'df6e4bf7-ad28-4444-aefe-31a4d00c0d7b','114d73a8-febd-47d4-a2bd-1520554fa012',2,'AAA',
'7a1046fa-5dc0-49ad-bd0e-60ada3e239fe');

INSERT INTO TR_PEMESANAN_JASA VALUES ('1f58bc66-d1e7-43bb-890d-c24d5e8805ea','2024-05-09 00:00:00',
'2024-05-11 00:00:00','2024-05-11 11:30:00',60000,'8192ca83-c52d-4350-8fa5-64b09cfc96b5',
'df6e4bf7-ad28-4444-aefe-31a4d00c0d7b','114d73a8-febd-47d4-a2bd-1520554fa012',2,'JASARUMAH30',
'7a1046fa-5dc0-49ad-bd0e-60ada3e239fe');

DELETE FROM TR_PEMESANAN_JASA WHERE id_tr_pemesanan_jasa = 'b0a3d6e1-ab36-4ad4-80e8-cee9fe64d60e';

UPDATE TR_PEMBELIAN_VOUCHER SET telah_digunakan = 4 WHERE id_tr_pembelian_voucher='0d9e50bb-4799-4738-9cac-b760032856f8';
0d9e50bb-4799-4738-9cac-b760032856f8

CREATE OR REPLACE FUNCTION validate_promo_usage()
RETURNS trigger AS
$$
BEGIN
    -- Check if the voucher exists in the VOUCHER table
    IF EXISTS (SELECT 1 FROM PROMO p WHERE NEW.id_diskon = p.kode) THEN
        
        -- Check if the voucher was purchased
        IF NEW.tgl_pemesanan > (SELECT tgl_akhir_berlaku FROM PROMO p WHERE NEW.id_diskon = p.kode) THEN
            RAISE EXCEPTION 'Promo sudah melewati batas tanggal akhir berlaku';
        END IF;
    END IF;

    RETURN NEW; -- Allow the operation if no conditions fail
END;
$$
LANGUAGE plpgsql;



-- Create a trigger to validate voucher usage before insert or update
CREATE TRIGGER trg_validate_promo_usage
BEFORE INSERT OR UPDATE ON TR_PEMESANAN_JASA
FOR EACH ROW 
EXECUTE FUNCTION validate_promo_usage();


CREATE OR REPLACE FUNCTION validate_discount_usage()
RETURNS trigger AS
$$
BEGIN
    -- Check if the id_diskon in the new row exists in the DISKON table
    IF NEW.id_diskon IS NOT NULL AND NOT EXISTS (
        SELECT 1 
        FROM DISKON d 
        WHERE d.kode = NEW.id_diskon
    ) THEN
        -- Raise an exception if the id_diskon is invalid
        RAISE EXCEPTION 'Diskon dengan kode % tidak ada', NEW.id_diskon;
    END IF;

    -- Return the NEW row to allow the operation
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_discount_usage
BEFORE INSERT OR UPDATE ON TR_PEMESANAN_JASA
FOR EACH ROW 
EXECUTE FUNCTION validate_discount_usage();




SELECT id_tr_pemesanan_jasa, pl.nama AS nama_pelanggan, pk.nama AS nama_pekerja, t.tgl, t.teks, t.rating  
                       FROM TESTIMONI t NATURAL JOIN TR_PEMESANAN_JASA tpj
                        JOIN USERS pl ON pl.id_user = tpj.id_pelanggan
                        JOIN USERS pk ON pk.id_user = tpj.id_pekerja
                        WHERE id_tr_pemesanan_jasa='1f58bc66-d1e7-43bb-890d-c24d5e8805ea'