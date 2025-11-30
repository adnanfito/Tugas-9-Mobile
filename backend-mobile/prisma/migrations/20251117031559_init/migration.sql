-- CreateTable
CREATE TABLE "member" (
    "id" SERIAL NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,

    CONSTRAINT "member_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "member_token" (
    "id" SERIAL NOT NULL,
    "auth_key" TEXT NOT NULL,
    "member_id" INTEGER NOT NULL,

    CONSTRAINT "member_token_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "produk" (
    "id" SERIAL NOT NULL,
    "kode_produk" TEXT NOT NULL,
    "nama_produk" TEXT NOT NULL,
    "harga" INTEGER NOT NULL,

    CONSTRAINT "produk_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "member_email_key" ON "member"("email");

-- CreateIndex
CREATE UNIQUE INDEX "produk_kode_produk_key" ON "produk"("kode_produk");

-- AddForeignKey
ALTER TABLE "member_token" ADD CONSTRAINT "member_token_member_id_fkey" FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE CASCADE;
