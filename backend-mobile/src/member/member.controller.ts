// src/member/member.controller.ts
import { Controller, Post, Body, HttpCode, HttpStatus } from '@nestjs/common';
import { MemberService } from './member.service';
import { RegistrasiMemberDto } from './dto/registrasi.dto';
import { LoginMemberDto } from './dto/login.dto';

@Controller('member') // <-- Prefix untuk semua rute di file ini
export class MemberController {
  constructor(private readonly memberService: MemberService) {}

  // Endpoint: POST /member/registrasi
  @Post('registrasi')
  async registrasi(@Body() dto: RegistrasiMemberDto) {
    return this.memberService.registrasi(dto);
  }

  // Endpoint: POST /member/login
  @HttpCode(HttpStatus.OK) // <-- Set HTTP status 200 OK (default POST adalah 201)
  @Post('login')
  async login(@Body() dto: LoginMemberDto) {
    return this.memberService.login(dto);
  }
}
