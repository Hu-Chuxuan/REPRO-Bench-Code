import Link from "next/link";
import { Button } from "@/components/ui/button";
import React from "react";
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet";
import Image from "next/image";
import getServerUser from "@/hooks/getServerUser";
import ProfileDropdown from "./ProfileDropdown";
import {
  IconCircleUser,
  IconMenu,
  IconPackage2,
  IconRefresh,
  IconSquareActivity,
  IconWorkFlow,
} from "@/components/ui/icons";
import AutoGPTServerAPI from "@/lib/autogpt-server-api";
import CreditButton from "@/components/CreditButton";
import { BsBoxes } from "react-icons/bs";
import { LuLaptop } from "react-icons/lu";
import { LuShoppingCart } from "react-icons/lu";

export async function NavBar() {
  const isAvailable = Boolean(
    process.env.NEXT_PUBLIC_SUPABASE_URL &&
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
  );
  const { user } = await getServerUser();

  return (
    <header className="sticky top-0 z-50 flex h-16 items-center gap-4 border-b bg-background px-4 md:rounded-b-3xl md:px-6 md:shadow-md">
      <div className="flex flex-1 items-center gap-4">
        <Sheet>
          <SheetTrigger asChild>
            <Button
              variant="outline"
              size="icon"
              className="shrink-0 md:hidden"
            >
              <IconMenu />
              <span className="sr-only">Toggle navigation menu</span>
            </Button>
          </SheetTrigger>
          <SheetContent side="left">
            <nav className="grid gap-6 text-lg font-medium">
              <Link
                href="/marketplace"
                className="mt-4 flex flex-row items-center gap-2 text-muted-foreground hover:text-foreground"
              >
                <LuShoppingCart /> Marketplace
              </Link>
              <Link
                href="/"
                className="flex flex-row items-center gap-2 text-muted-foreground hover:text-foreground"
              >
                <LuLaptop /> Monitor
              </Link>
              <Link
                href="/build"
                className="flex flex-row items-center gap-2 text-muted-foreground hover:text-foreground"
              >
                <BsBoxes /> Build
              </Link>
            </nav>
          </SheetContent>
        </Sheet>
        <nav className="hidden md:flex md:flex-row md:items-center md:gap-7 lg:gap-8">
          <div className="flex h-10 w-20 flex-1 flex-row items-center justify-center gap-2">
            <a href="https://agpt.co/">
              <Image
                src="/AUTOgpt_Logo_dark.png"
                alt="AutoGPT Logo"
                width={100}
                height={40}
                priority
              />
            </a>
          </div>
          <Link
            href="/marketplace"
            className="text-basehover:text-foreground flex flex-row items-center gap-2 font-semibold text-foreground"
          >
            <LuShoppingCart /> Marketplace
          </Link>
          <Link
            href="/"
            className="text-basehover:text-foreground flex flex-row items-center gap-2 font-semibold text-foreground"
          >
            <LuLaptop className="mr-1" /> Monitor
          </Link>
          <Link
            href="/build"
            className="flex flex-row items-center gap-2 text-base font-semibold text-foreground hover:text-foreground"
          >
            <BsBoxes className="mr-1" /> Build
          </Link>
        </nav>
      </div>
      <div className="flex flex-1 items-center justify-end gap-4">
        {isAvailable && user && <CreditButton />}

        {isAvailable && !user && (
          <Link
            href="/login"
            className="flex flex-row items-center gap-2 text-muted-foreground hover:text-foreground"
          >
            Log In
            <IconCircleUser />
          </Link>
        )}
        {isAvailable && user && <ProfileDropdown />}
      </div>
    </header>
  );
}
