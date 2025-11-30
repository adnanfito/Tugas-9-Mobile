// src/prisma/prisma.module.ts
import { Global, Module } from '@nestjs/common';
import { PrismaService } from './prisma.service';

@Global() // <-- Penting! Membuat service ini tersedia di semua modul lain
@Module({
  providers: [PrismaService],
  exports: [PrismaService], // <-- Ekspor service-nya
})
export class PrismaModule {}
