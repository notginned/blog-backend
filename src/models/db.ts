import { loadEnvFile } from "process";
import { PrismaPg } from "@prisma/adapter-pg";
import { PrismaClient } from "../../generated/prisma/client.js";

loadEnvFile();
let dbClient: null | PrismaClient = null;

const getDb = () => {
  if (dbClient) return dbClient;

  const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL });
  dbClient = new PrismaClient({ adapter });

  return dbClient;
};

export { getDb };
