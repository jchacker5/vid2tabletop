# Vid2Tabletop

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Vid2Tabletop is an open-source MVP app that converts NBA game videos into an interactive 3D tabletop format. The system uses modern computer vision and reinforcement learning techniques to extract game events, player positions, and tactical insights from video footage.

## Features

- **Video Processing & Preprocessing:**
  - Ingest and process YouTube videos (NBA clips)
  - Data augmentation and annotation
- **Object Detection & Tracking:**
  - Player detection and tracking
  - Ball tracking
  - Court marking detection
- **Game State Analysis:**
  - Tactical 3D representation
  - Player movement analysis
  - Play pattern recognition
- **Interactive Interface:**
  - Modern web interface built with Next.js 14
  - Real-time 3D visualization
  - Intuitive controls

## Tech Stack

- **Frontend:**

  - Next.js 14 (App Router)
  - TypeScript
  - Tailwind CSS
  - Shadcn UI
  - Three.js (for 3D visualization)

- **Backend:**
  - Supabase
  - YouTube Data API
  - TensorFlow.js

## Getting Started

### Prerequisites

- Node.js 18+
- YouTube API Key
- Supabase Account

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/jchacker5/vid2tabletop.git
   cd vid2tabletop
   ```

2. Install dependencies:

   ```bash
   npm install
   ```

3. Copy the environment variables:

   ```bash
   cp .env.example .env.local
   ```

4. Add your API keys to `.env.local`

5. Start the development server:

   ```bash
   npm run dev
   ```

6. Open [http://localhost:3000](http://localhost:3000) in your browser

## Project Structure

```
vid2tabletop/
├── app/                      # Next.js app directory
│   ├── layout.tsx           # Root layout
│   └── page.tsx             # Home page
├── components/              # React components
│   ├── ui/                  # UI components
│   └── video-upload.tsx     # Video upload component
├── lib/                     # Utility functions
│   ├── utils.ts            # Helper functions
│   └── youtube.ts          # YouTube API integration
└── public/                  # Static assets
```

## Contributing

We welcome contributions! Please see our contributing guide for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Thanks to the open-source community
- Inspired by sports analytics research
- Built with modern web technologies

---

For more information, please visit our [GitHub repository](https://github.com/jchacker5/vid2tabletop) or check out the [documentation](docs/README.md).
