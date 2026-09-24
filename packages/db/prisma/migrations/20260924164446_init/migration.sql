-- CreateEnum
CREATE TYPE "source_status" AS ENUM ('verified', 'candidate', 'rejected');

-- CreateEnum
CREATE TYPE "source_region" AS ENUM ('local_ke', 'international');

-- CreateTable
CREATE TABLE "user_profile" (
    "user_id" TEXT NOT NULL,
    "telegram_chat_id" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_profile_pkey" PRIMARY KEY ("user_id")
);

-- CreateTable
CREATE TABLE "sources" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "name" TEXT NOT NULL,
    "base_url" TEXT NOT NULL,
    "domain" TEXT NOT NULL,
    "region" "source_region" NOT NULL,
    "status" "source_status" NOT NULL DEFAULT 'verified',
    "extraction_mode" TEXT NOT NULL DEFAULT 'llm',
    "discovered_via" TEXT,
    "raw_snippet" TEXT,
    "reviewed_at" TIMESTAMPTZ(6),
    "reviewed_by" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "sources_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "wishlist_items" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "target_specs" JSONB NOT NULL DEFAULT '{}',
    "image_url" TEXT,
    "image_source_offer_id" UUID,
    "weight_kg" DECIMAL(8,3),
    "weight_source_offer_id" UUID,
    "status" TEXT NOT NULL DEFAULT 'active',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "wishlist_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "source_offers" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "wishlist_item_id" UUID NOT NULL,
    "source_id" UUID NOT NULL,
    "external_url" TEXT NOT NULL,
    "external_url_normalized" TEXT NOT NULL,
    "title_raw" TEXT NOT NULL,
    "specs_raw" JSONB NOT NULL DEFAULT '{}',
    "match_confidence" DECIMAL(4,3),
    "match_reason" TEXT,
    "review_status" TEXT NOT NULL DEFAULT 'auto',
    "in_stock" BOOLEAN,
    "currency" TEXT NOT NULL,
    "image_url" TEXT,
    "weight_kg" DECIMAL(8,3),
    "first_seen_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "last_checked_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "source_offers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "price_snapshots" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "source_offer_id" UUID NOT NULL,
    "price" DECIMAL(12,2) NOT NULL,
    "currency" TEXT NOT NULL,
    "fx_rate_to_kes" DECIMAL(12,6),
    "landed_cost_kes" DECIMAL(12,2),
    "checked_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "price_snapshots_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "shipping_routes" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "origin_country" TEXT NOT NULL,
    "forwarder_name" TEXT NOT NULL,
    "rate_per_kg_kes" DECIMAL(10,2),
    "volumetric_divisor" DECIMAL(10,2),
    "base_fee_kes" DECIMAL(10,2),
    "duty_estimate_pct" DECIMAL(5,2),
    "status" "source_status" NOT NULL DEFAULT 'candidate',
    "is_default_fallback" BOOLEAN NOT NULL DEFAULT false,
    "discovered_via" TEXT,
    "reviewed_at" TIMESTAMPTZ(6),
    "reviewed_by" TEXT,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "shipping_routes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "fx_rates" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "base_currency" TEXT NOT NULL,
    "quote_currency" TEXT NOT NULL,
    "rate" DECIMAL(14,6) NOT NULL,
    "fetched_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "fx_rates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "alert_rules" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "wishlist_item_id" UUID NOT NULL,
    "bands" JSONB NOT NULL DEFAULT '[[5,10],[10,15],[15,20],[20,999]]',
    "notify_on_rise" BOOLEAN NOT NULL DEFAULT true,
    "channels" TEXT[] DEFAULT ARRAY['email', 'telegram']::TEXT[],
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "alert_rules_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "alert_state" (
    "wishlist_item_id" UUID NOT NULL,
    "reference_price_kes" DECIMAL(12,2),
    "last_notified_band" TEXT,
    "last_direction" TEXT,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "alert_state_pkey" PRIMARY KEY ("wishlist_item_id")
);

-- CreateTable
CREATE TABLE "notification_log" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "wishlist_item_id" UUID NOT NULL,
    "channel" TEXT NOT NULL,
    "direction" TEXT NOT NULL,
    "band" TEXT,
    "price_from_kes" DECIMAL(12,2),
    "price_to_kes" DECIMAL(12,2),
    "best_source_offer_id" UUID,
    "sent_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "status" TEXT NOT NULL DEFAULT 'sent',

    CONSTRAINT "notification_log_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "job_runs" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "job_type" TEXT NOT NULL,
    "trigger" TEXT NOT NULL,
    "trace_id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "status" TEXT NOT NULL DEFAULT 'running',
    "started_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "finished_at" TIMESTAMPTZ(6),

    CONSTRAINT "job_runs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "job_run_targets" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "job_run_id" UUID NOT NULL,
    "target_type" TEXT NOT NULL,
    "target_id" UUID,
    "attempt_count" INTEGER NOT NULL DEFAULT 1,
    "status" TEXT NOT NULL DEFAULT 'pending',
    "error_message" TEXT,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "job_run_targets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "emailVerified" BOOLEAN NOT NULL DEFAULT false,
    "image" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "user_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "session" (
    "id" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "token" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "ipAddress" TEXT,
    "userAgent" TEXT,
    "userId" TEXT NOT NULL,

    CONSTRAINT "session_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "account" (
    "id" TEXT NOT NULL,
    "accountId" TEXT NOT NULL,
    "providerId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "accessToken" TEXT,
    "refreshToken" TEXT,
    "idToken" TEXT,
    "accessTokenExpiresAt" TIMESTAMP(3),
    "refreshTokenExpiresAt" TIMESTAMP(3),
    "scope" TEXT,
    "password" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "account_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "verification" (
    "id" TEXT NOT NULL,
    "identifier" TEXT NOT NULL,
    "value" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "verification_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "sources_domain_key" ON "sources"("domain");

-- CreateIndex
CREATE UNIQUE INDEX "source_offers_source_id_external_url_normalized_key" ON "source_offers"("source_id", "external_url_normalized");

-- CreateIndex
CREATE INDEX "price_snapshots_source_offer_id_checked_at_idx" ON "price_snapshots"("source_offer_id", "checked_at" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "fx_rates_base_currency_quote_currency_fetched_at_key" ON "fx_rates"("base_currency", "quote_currency", "fetched_at");

-- CreateIndex
CREATE UNIQUE INDEX "alert_rules_wishlist_item_id_key" ON "alert_rules"("wishlist_item_id");

-- CreateIndex
CREATE INDEX "job_run_targets_status_attempt_count_idx" ON "job_run_targets"("status", "attempt_count");

-- CreateIndex
CREATE UNIQUE INDEX "user_email_key" ON "user"("email");

-- CreateIndex
CREATE INDEX "session_userId_idx" ON "session"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "session_token_key" ON "session"("token");

-- CreateIndex
CREATE INDEX "account_userId_idx" ON "account"("userId");

-- CreateIndex
CREATE INDEX "verification_identifier_idx" ON "verification"("identifier");

-- AddForeignKey
ALTER TABLE "user_profile" ADD CONSTRAINT "user_profile_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sources" ADD CONSTRAINT "sources_reviewed_by_fkey" FOREIGN KEY ("reviewed_by") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "wishlist_items" ADD CONSTRAINT "wishlist_items_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "wishlist_items" ADD CONSTRAINT "wishlist_items_image_source_offer_id_fkey" FOREIGN KEY ("image_source_offer_id") REFERENCES "source_offers"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "wishlist_items" ADD CONSTRAINT "wishlist_items_weight_source_offer_id_fkey" FOREIGN KEY ("weight_source_offer_id") REFERENCES "source_offers"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "source_offers" ADD CONSTRAINT "source_offers_wishlist_item_id_fkey" FOREIGN KEY ("wishlist_item_id") REFERENCES "wishlist_items"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "source_offers" ADD CONSTRAINT "source_offers_source_id_fkey" FOREIGN KEY ("source_id") REFERENCES "sources"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "price_snapshots" ADD CONSTRAINT "price_snapshots_source_offer_id_fkey" FOREIGN KEY ("source_offer_id") REFERENCES "source_offers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "shipping_routes" ADD CONSTRAINT "shipping_routes_reviewed_by_fkey" FOREIGN KEY ("reviewed_by") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "alert_rules" ADD CONSTRAINT "alert_rules_wishlist_item_id_fkey" FOREIGN KEY ("wishlist_item_id") REFERENCES "wishlist_items"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "alert_state" ADD CONSTRAINT "alert_state_wishlist_item_id_fkey" FOREIGN KEY ("wishlist_item_id") REFERENCES "wishlist_items"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notification_log" ADD CONSTRAINT "notification_log_wishlist_item_id_fkey" FOREIGN KEY ("wishlist_item_id") REFERENCES "wishlist_items"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notification_log" ADD CONSTRAINT "notification_log_best_source_offer_id_fkey" FOREIGN KEY ("best_source_offer_id") REFERENCES "source_offers"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "job_run_targets" ADD CONSTRAINT "job_run_targets_job_run_id_fkey" FOREIGN KEY ("job_run_id") REFERENCES "job_runs"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "session" ADD CONSTRAINT "session_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "account" ADD CONSTRAINT "account_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;
