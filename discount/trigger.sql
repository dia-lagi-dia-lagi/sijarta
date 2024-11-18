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





--- Check if its a voucher
--- Voucher
--- Search in TR_PEMESANAN_JASA using the idPelanngan
--- count how many rows are there
--- if the rows exceed the Voucher Limit -> Error
--- Count how many days from purchaes to the time limit
--- If the time limit exceeds it -> Error


END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_voucher_usage()
BEFORE INSERT OR UPDATE ON TR_PEMESANAN_JASA
FOR EACH ROW EXECUTE PROCEDURE validate_voucher_usage();