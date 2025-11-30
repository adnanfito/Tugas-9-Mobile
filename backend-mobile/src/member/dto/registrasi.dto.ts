// src/member/dto/registrasi.dto.ts
import { IsEmail, IsNotEmpty, IsString, MinLength } from 'class-validator';

export class RegistrasiMemberDto {
  @IsString()
  @IsNotEmpty()
  nama: string;

  @IsEmail()
  @IsNotEmpty()
  email: string;

  @IsString()
  @IsNotEmpty()
  @MinLength(6) // Password minimal 6 karakter
  password: string;
}
