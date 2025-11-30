// src/produk/dto/update-produk.dto.ts
import { PartialType } from '@nestjs/mapped-types'; // NestJS otomatis generate ini
import { CreateProdukDto } from './create-produk.dto';

export class UpdateProdukDto extends PartialType(CreateProdukDto) {}
