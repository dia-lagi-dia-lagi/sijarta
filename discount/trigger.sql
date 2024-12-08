CREATE OR REPLACE FUNCTION validate_voucher_usage()
RETURNS trigger AS
$$

BEGIN
IF (NEW.id_diskon IN VOUCHER.kode) THEN
    IF (
        SELECT COUNT(*) FROM TR_PEMESANAN_JASA 
        WHERE NEW.id_pelanggan = TR_PEMESANAN_JASA.id_pelanggan AND
        NEW.id_diskon = TR_PEMESANAN_JASA.id_diskon
    ) > (
        SELECT VOUCHER.kuota_penggunaan FROM VOUCHER
        WHERE NEW.id_diskon = VOUCHER.kode
    ) THEN

    ELSIF () THEN

    END IF;


END IF;




END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_voucher_usage()
BEFORE INSERT OR UPDATE ON TR_PEMESANAN_JASA
FOR EACH ROW EXECUTE PROCEDURE validate_voucher_usage();

 SELECT COUNT(*) FROM TR_PEMESANAN_JASA 
WHERE id_pelanggan = '8192ca83-c52d-4350-8fa5-64b09cfc96b5' AND
id_diskon = 'SPESIALRUMAH2024';