import {
  Controller,
  Post,
  Body,
  Get,
  Param,
  Put,
  Delete,
  UseGuards,
} from '@nestjs/common';
import { ProdukService } from './produk.service';
import { CreateProdukDto } from './dto/create-produk.dto';
import { UpdateProdukDto } from './dto/update-produk.dto';

@Controller('produk')
export class ProdukController {
  constructor(private produkService: ProdukService) {}

  @Post()
  async create(@Body() createProdukDto: CreateProdukDto) {
    try {
      console.log('🔵 [Create Produk] Received:', createProdukDto);

      // ✅ Validation
      if (
        !createProdukDto.kode_produk ||
        !createProdukDto.nama_produk ||
        !createProdukDto.harga
      ) {
        throw new Error('Missing required fields');
      }

      const result = await this.produkService.create(createProdukDto);
      console.log('🟢 [Create Produk] Success:', result);

      return {
        code: 200,
        status: true,
        message: 'Produk berhasil ditambahkan',
        data: result,
      };
    } catch (error) {
      console.error('🔴 [Create Produk] Error:', error.message);
      return {
        code: 500,
        status: false,
        message: error.message || 'Gagal menambahkan produk',
      };
    }
  }

  @Get()
  async findAll() {
    try {
      const result = await this.produkService.findAll();
      return {
        code: 200,
        status: true,
        data: result,
      };
    } catch (error) {
      console.error('🔴 [Get Produks] Error:', error.message);
      return {
        code: 500,
        status: false,
        message: error.message,
      };
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    try {
      const result = await this.produkService.findOne(+id);
      return {
        code: 200,
        status: true,
        data: result,
      };
    } catch (error) {
      console.error('🔴 [Get Produk] Error:', error.message);
      return {
        code: 500,
        status: false,
        message: error.message,
      };
    }
  }

  @Put(':id/update')
  async update(
    @Param('id') id: string,
    @Body() updateProdukDto: UpdateProdukDto,
  ) {
    try {
      const result = await this.produkService.update(+id, updateProdukDto);
      return {
        code: 200,
        status: true,
        message: 'Produk berhasil diupdate',
        data: result,
      };
    } catch (error) {
      console.error('🔴 [Update Produk] Error:', error.message);
      return {
        code: 500,
        status: false,
        message: error.message,
      };
    }
  }

  @Delete(':id')
  async remove(@Param('id') id: string) {
    try {
      await this.produkService.remove(+id);
      return {
        code: 200,
        status: true,
        message: 'Produk berhasil dihapus',
      };
    } catch (error) {
      console.error('🔴 [Delete Produk] Error:', error.message);
      return {
        code: 500,
        status: false,
        message: error.message,
      };
    }
  }
}
