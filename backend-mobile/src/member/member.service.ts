// src/member/member.service.ts
import {
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';
import { RegistrasiMemberDto } from './dto/registrasi.dto';
import { LoginMemberDto } from './dto/login.dto';
import * as bcrypt from 'bcrypt';
import { JwtService } from '@nestjs/jwt';

@Injectable()
export class MemberService {
  // Suntik PrismaService dan JwtService
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  // --- FUNGSI REGISTRASI ---
  async registrasi(dto: RegistrasiMemberDto) {
    // 1. Hash password
    const hashedPassword = await bcrypt.hash(dto.password, 10);

    try {
      // 2. Simpan ke database
      const newMember = await this.prisma.member.create({
        data: {
          nama: dto.nama,
          email: dto.email,
          password: hashedPassword,
        },
      });

      // 3. Kembalikan data (sesuai format response Anda)
      return {
        code: 201,
        status: true,
        data: 'Registrasi berhasil',
      };
    } catch (error) {
      // Tangani jika email sudah terdaftar (Prisma error code P2002)
      if (error.code === 'P2002') {
        throw new ConflictException('Email sudah terdaftar');
      }
      throw error;
    }
  }

  // --- FUNGSI LOGIN ---
  async login(dto: LoginMemberDto) {
    // 1. Cari member berdasarkan email
    const member = await this.prisma.member.findUnique({
      where: { email: dto.email },
    });

    // 2. Jika member tidak ada, lempar error
    if (!member) {
      throw new UnauthorizedException('Email atau password salah');
    }

    // 3. Bandingkan password
    const isPasswordMatch = await bcrypt.compare(dto.password, member.password);

    // 4. Jika password salah, lempar error
    if (!isPasswordMatch) {
      throw new UnauthorizedException('Email atau password salah');
    }

    // 5. Jika sukses, buat JWT Token
    const payload = { sub: member.id, email: member.email };
    const token = await this.jwtService.signAsync(payload);

    // 6. Kembalikan data (sesuai format response Anda)
    return {
      code: 200,
      status: true,
      data: {
        token: token,
        user: {
          id: member.id,
          email: member.email,
        },
      },
    };
  }
}
