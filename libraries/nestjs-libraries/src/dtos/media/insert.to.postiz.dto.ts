import { IsDefined, IsOptional, IsString } from 'class-validator';
import { ValidUrlExtension } from '@gitroom/helpers/utils/valid.url.path';


export class InsertToPostizDto {
  @IsString()
  @IsDefined()
  @Validate(ValidUrlExtension)
  r2_url: string;

  @IsString()
  @IsOptional()
  name?: string;
}
