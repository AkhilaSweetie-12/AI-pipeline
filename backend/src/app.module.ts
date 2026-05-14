import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { ThrottlerModule } from '@nestjs/throttler';
import { TerminusModule } from '@nestjs/terminus';
import { BullModule } from '@nestjs/bull';
import { PrismaModule } from './database/prisma.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { ChatModule } from './chat/chat.module';
import { PromptsModule } from './prompts/prompts.module';
import { MetricsModule } from './metrics/metrics.module';
import { FilesModule } from './files/files.module';
import { HealthModule } from './common/health/health.module';
import configuration from './config/configuration';

@Module({
  imports: [
    // Configuration
    ConfigModule.forRoot({
      isGlobal: true,
      load: [configuration],
      envFilePath: ['.env.local', '.env'],
    }),

    // Rate limiting
    ThrottlerModule.forRoot([
      {
        ttl: 60000, // 1 minute
        limit: 100, // 100 requests per minute
      },
    ]),

    // Health checks
    TerminusModule.forRoot({
      logger: false,
    }),

    // Queue system
    BullModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => ({
        redis: {
          host: configService.get('REDIS_HOST'),
          port: configService.get('REDIS_PORT'),
          password: configService.get('REDIS_PASSWORD'),
        },
      }),
      inject: [ConfigService],
    }),

    // Database
    PrismaModule,

    // Feature modules
    AuthModule,
    UsersModule,
    ChatModule,
    PromptsModule,
    MetricsModule,
    FilesModule,
    HealthModule,
  ],
  controllers: [],
  providers: [],
})
export class AppModule {}
