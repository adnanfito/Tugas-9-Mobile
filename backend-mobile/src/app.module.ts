// src/app.module.ts
import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
// import { ProdukModule } from './produk/produk.module';
import { JwtModule } from '@nestjs/jwt'; // <-- 1. IMPORT
import { MemberModule } from './member/member.module';
import { ProdukModule } from './produk/produk.module';

@Module({
  imports: [
    PrismaModule,
    // ProdukModule,
    // Daftarkan JWT Module secara Global
    JwtModule.register({
      global: true, // <-- 2. BUAT GLOBAL
      secret: 'sklibit-sklibawh-mantapnyoo', // <-- 3. GANTI DENGAN KATA RAHASIA
      signOptions: { expiresIn: '1d' }, // <-- 4. Token berlaku 1 hari
    }),
    MemberModule,
    ProdukModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
