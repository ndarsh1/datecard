import dotenv from "dotenv";
dotenv.config();

import { supabaseAdmin } from "../services/supabase";

interface DateExperience {
  title: string;
  description: string;
  categories: string[];
  neighborhood: string;
  latitude: number;
  longitude: number;
  price_range: number;
  duration_minutes: number;
  source: string;
  is_venue_package: boolean;
  hero_image: string;
  gallery_images: string[];
  opt_in_count: number;
}

const experiences: DateExperience[] = [
  {
    title: "Sunset Rooftop Cocktails at The Beacon",
    description:
      "Share craft cocktails and small plates on a rooftop terrace overlooking the Long Island Sound as the sun dips below the horizon. Perfect for a first date or a special evening.",
    categories: ["dinner_and_drinks"],
    neighborhood: "Harbor Point, Stamford",
    latitude: 41.0465,
    longitude: -73.5385,
    price_range: 3,
    duration_minutes: 120,
    source: "venue",
    is_venue_package: true,
    hero_image: "",
    gallery_images: [],
    opt_in_count: 0,
  },
  {
    title: "Kayak & Picnic on Holly Pond",
    description:
      "Paddle tandem kayaks across Holly Pond, then dock at the south shore for a pre-packed gourmet picnic. Serene nature minutes from downtown.",
    categories: ["outdoor_adventure"],
    neighborhood: "Cove Island Park, Stamford",
    latitude: 41.0548,
    longitude: -73.5189,
    price_range: 2,
    duration_minutes: 180,
    source: "editorial",
    is_venue_package: false,
    hero_image: "",
    gallery_images: [],
    opt_in_count: 0,
  },
  {
    title: "Jazz Night at Stamford's Listening Room",
    description:
      "Intimate live jazz in a candlelit lounge. Features rotating local quartets performing classic and modern jazz. Wine and dessert menu available.",
    categories: ["live_music"],
    neighborhood: "Bedford Street, Stamford",
    latitude: 41.0534,
    longitude: -73.5387,
    price_range: 2,
    duration_minutes: 150,
    source: "venue",
    is_venue_package: true,
    hero_image: "",
    gallery_images: [],
    opt_in_count: 0,
  },
  {
    title: "Handmade Pasta Workshop for Two",
    description:
      "Roll, cut, and cook fresh pasta from scratch side-by-side with a professional Italian chef. End the evening enjoying your creation with paired wines.",
    categories: ["cooking", "dinner_and_drinks"],
    neighborhood: "Summer Street, Stamford",
    latitude: 41.0516,
    longitude: -73.5434,
    price_range: 3,
    duration_minutes: 150,
    source: "venue",
    is_venue_package: true,
    hero_image: "",
    gallery_images: [],
    opt_in_count: 0,
  },
  {
    title: "Gallery Walk & Wine Through SoNo",
    description:
      "Stroll through three contemporary art galleries in the SoNo district, with a complimentary glass of wine at each stop. End at a waterfront wine bar.",
    categories: ["art_and_culture"],
    neighborhood: "South Norwalk, CT",
    latitude: 41.0951,
    longitude: -73.4209,
    price_range: 2,
    duration_minutes: 180,
    source: "editorial",
    is_venue_package: false,
    hero_image: "",
    gallery_images: [],
    opt_in_count: 0,
  },
  {
    title: "Indoor Rock Climbing Challenge",
    description:
      "Hit the climbing wall together at a premier bouldering gym. No experience needed — instructors guide beginners, and experienced climbers can tackle advanced routes.",
    categories: ["sports"],
    neighborhood: "Tresser Boulevard, Stamford",
    latitude: 41.0487,
    longitude: -73.5421,
    price_range: 2,
    duration_minutes: 120,
    source: "community",
    is_venue_package: false,
    hero_image: "",
    gallery_images: [],
    opt_in_count: 0,
  },
  {
    title: "Speakeasy Crawl Through Downtown",
    description:
      "Discover three hidden cocktail bars tucked behind unmarked doors in downtown Stamford. Each stop features a signature drink and a small surprise.",
    categories: ["nightlife"],
    neighborhood: "Downtown Stamford",
    latitude: 41.0528,
    longitude: -73.5393,
    price_range: 3,
    duration_minutes: 180,
    source: "editorial",
    is_venue_package: false,
    hero_image: "",
    gallery_images: [],
    opt_in_count: 0,
  },
  {
    title: "Couples Yoga & Meditation at Dawn",
    description:
      "Start the day with a guided partner yoga flow on the waterfront, followed by a 20-minute meditation and herbal tea service.",
    categories: ["wellness"],
    neighborhood: "Mill River Park, Stamford",
    latitude: 41.0562,
    longitude: -73.5398,
    price_range: 1,
    duration_minutes: 90,
    source: "community",
    is_venue_package: false,
    hero_image: "",
    gallery_images: [],
    opt_in_count: 0,
  },
  {
    title: "Latte Art Throwdown & Brunch",
    description:
      "Compete in a friendly latte art challenge at a specialty coffee roaster, then settle in for a seasonal brunch with house-made pastries.",
    categories: ["coffee_and_brunch"],
    neighborhood: "Atlantic Street, Stamford",
    latitude: 41.0509,
    longitude: -73.5419,
    price_range: 1,
    duration_minutes: 90,
    source: "venue",
    is_venue_package: false,
    hero_image: "",
    gallery_images: [],
    opt_in_count: 0,
  },
  {
    title: "Retro Arcade & Board Game Night",
    description:
      "Challenge each other to classic arcade games and over 200 board games at a retro-themed game cafe. Snacks and craft sodas included.",
    categories: ["games"],
    neighborhood: "Hope Street, Stamford",
    latitude: 41.0571,
    longitude: -73.5373,
    price_range: 1,
    duration_minutes: 150,
    source: "venue",
    is_venue_package: true,
    hero_image: "",
    gallery_images: [],
    opt_in_count: 0,
  },
  {
    title: "Day Trip to Coastal Vineyards",
    description:
      "A curated day trip to two boutique vineyards along the Connecticut coast. Includes tastings, a vineyard tour, and a charcuterie lunch.",
    categories: ["travel", "dinner_and_drinks"],
    neighborhood: "Connecticut Coast",
    latitude: 41.0781,
    longitude: -73.4612,
    price_range: 3,
    duration_minutes: 240,
    source: "editorial",
    is_venue_package: false,
    hero_image: "",
    gallery_images: [],
    opt_in_count: 0,
  },
  {
    title: "Beach Cleanup & Bonfire",
    description:
      "Make a difference together by cleaning up Cummings Beach, then reward yourselves with a beachside bonfire, s'mores, and hot chocolate.",
    categories: ["volunteering"],
    neighborhood: "Cummings Beach, Stamford",
    latitude: 41.0402,
    longitude: -73.5251,
    price_range: 1,
    duration_minutes: 180,
    source: "community",
    is_venue_package: false,
    hero_image: "",
    gallery_images: [],
    opt_in_count: 0,
  },
  {
    title: "Farm-to-Table Dinner Under the Stars",
    description:
      "A multi-course dinner prepared by a local chef using ingredients from nearby farms, served at a long communal table in a lantern-lit garden.",
    categories: ["dinner_and_drinks"],
    neighborhood: "North Stamford",
    latitude: 41.0892,
    longitude: -73.5601,
    price_range: 3,
    duration_minutes: 180,
    source: "editorial",
    is_venue_package: false,
    hero_image: "",
    gallery_images: [],
    opt_in_count: 0,
  },
  {
    title: "Trail Run & Smoothie Date",
    description:
      "Hit the trails at Mianus River Park for a scenic 5K run, then cool down with fresh smoothies at a nearby juice bar. All paces welcome.",
    categories: ["outdoor_adventure"],
    neighborhood: "Mianus River Park, Stamford",
    latitude: 41.0718,
    longitude: -73.5748,
    price_range: 1,
    duration_minutes: 120,
    source: "community",
    is_venue_package: false,
    hero_image: "",
    gallery_images: [],
    opt_in_count: 0,
  },
  {
    title: "Open Mic Poetry & Espresso",
    description:
      "Listen to — or bravely perform — spoken word poetry at an open mic night in a cozy coffee house. Espresso drinks and small bites on the house.",
    categories: ["live_music"],
    neighborhood: "Glenbrook, Stamford",
    latitude: 41.0615,
    longitude: -73.5291,
    price_range: 1,
    duration_minutes: 120,
    source: "community",
    is_venue_package: false,
    hero_image: "",
    gallery_images: [],
    opt_in_count: 0,
  },
  {
    title: "Sushi Rolling Masterclass",
    description:
      "Learn the art of sushi-making from a trained itamae. Roll maki, shape nigiri, and plate like a pro — then enjoy your creations with sake pairings.",
    categories: ["cooking", "dinner_and_drinks"],
    neighborhood: "Shippan, Stamford",
    latitude: 41.0395,
    longitude: -73.5442,
    price_range: 3,
    duration_minutes: 150,
    source: "venue",
    is_venue_package: true,
    hero_image: "",
    gallery_images: [],
    opt_in_count: 0,
  },
  {
    title: "Drive-In Movie Night",
    description:
      "Catch a double feature at a pop-up drive-in cinema. Blankets, popcorn, and candy bar provided. Classic rom-com and action picks rotate weekly.",
    categories: ["nightlife"],
    neighborhood: "Scalzi Park, Stamford",
    latitude: 41.0645,
    longitude: -73.5512,
    price_range: 2,
    duration_minutes: 240,
    source: "editorial",
    is_venue_package: false,
    hero_image: "",
    gallery_images: [],
    opt_in_count: 0,
  },
  {
    title: "Float Therapy & Tea Ceremony",
    description:
      "Unwind in a sensory deprivation float tank, followed by a guided Japanese-style tea ceremony. Total tranquility for two.",
    categories: ["wellness"],
    neighborhood: "High Ridge Road, Stamford",
    latitude: 41.0734,
    longitude: -73.5552,
    price_range: 2,
    duration_minutes: 120,
    source: "venue",
    is_venue_package: true,
    hero_image: "",
    gallery_images: [],
    opt_in_count: 0,
  },
  {
    title: "Escape Room: The Speakeasy Mystery",
    description:
      "Work together to crack codes, find hidden clues, and escape a Prohibition-era speakeasy room in under 60 minutes. Teamwork makes or breaks it.",
    categories: ["games"],
    neighborhood: "Washington Boulevard, Stamford",
    latitude: 41.0503,
    longitude: -73.5465,
    price_range: 2,
    duration_minutes: 75,
    source: "venue",
    is_venue_package: true,
    hero_image: "",
    gallery_images: [],
    opt_in_count: 0,
  },
  {
    title: "Animal Shelter Puppy Playdate",
    description:
      "Spend an afternoon socializing rescue puppies at a local animal shelter. Walk dogs, play fetch, and feel great knowing you helped with their socialization training.",
    categories: ["volunteering"],
    neighborhood: "Newfield, Stamford",
    latitude: 41.0682,
    longitude: -73.5328,
    price_range: 1,
    duration_minutes: 120,
    source: "community",
    is_venue_package: false,
    hero_image: "",
    gallery_images: [],
    opt_in_count: 0,
  },
];

async function seed() {
  console.log("Seeding date_experiences table with 20 experiences...\n");

  const { data, error } = await supabaseAdmin
    .from("date_experiences")
    .insert(experiences)
    .select();

  if (error) {
    console.error("Seed failed:", error.message);
    process.exit(1);
  }

  console.log(`Successfully inserted ${data.length} experiences:`);
  for (const exp of data) {
    console.log(`  - [${exp.categories}] ${exp.title}`);
  }

  process.exit(0);
}

seed();
