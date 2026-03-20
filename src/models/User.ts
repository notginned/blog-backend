import { getDb } from "./db.js";

type RoleType = "ADMIN" | "USER" | "GUEST";

interface createUserArgs {
  username: string;
  password: string;
}

interface User {
  id: number;
  username: string;
  password: string;
  role: RoleType;
  profilePicture?: string;
}

const users = getDb().user;

export const getUserById = async ({ id }: Pick<User, "id">) =>
  users.findUnique({
    where: { id },
    select: {
      id: true,
      username: true,
      profilePicture: true,
      role: true,
      comments: true,
      posts: true,
    },
  });

export const authenticateUser = async ({
  username,
  password,
}: Pick<User, "username" | "password">) => {
  const user = await users.findUnique({ where: { username, password } });
  if (user) return user;

  return false;
};

export const getUserByUsername = async ({ username }: Pick<User, "username">) =>
  users.findUnique({ where: { username } });

export const getAllUsers = async () => users.findMany();

export const createUser = async ({
  username,
  password,
}: Pick<User, "username" | "password">) =>
  users.create({
    data: {
      username,
      password,
      role: { connect: { type: "user" } },
    },
  });

export const updateUser = async () => {};
