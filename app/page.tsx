import { ThemeToggle } from "@/components/theme-toggle";
import { Button } from "@/components/ui/button";
import { VideoUpload } from "@/components/video-upload";

export default function Home() {
  return (
    <main className="min-h-screen bg-background">
      <nav className="border-b">
        <div className="container flex h-16 items-center px-4">
          <h1 className="text-2xl font-bold">Vid2Tabletop</h1>
          <div className="ml-auto">
            <ThemeToggle />
          </div>
        </div>
      </nav>

      <div className="container px-4 py-8">
        <div className="mx-auto max-w-2xl">
          <div className="rounded-lg border bg-card p-8">
            <h2 className="text-xl font-semibold mb-4">
              Upload NBA Game Video
            </h2>
            <VideoUpload />
          </div>

          <div className="mt-8 space-y-4">
            <div className="rounded-lg border bg-card p-6">
              <h3 className="font-medium mb-2">Processing Pipeline</h3>
              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <span className="text-sm">Video Preprocessing</span>
                  <span className="text-sm text-muted-foreground">
                    Waiting...
                  </span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-sm">Object Detection</span>
                  <span className="text-sm text-muted-foreground">
                    Waiting...
                  </span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-sm">Game State Analysis</span>
                  <span className="text-sm text-muted-foreground">
                    Waiting...
                  </span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-sm">3D Conversion</span>
                  <span className="text-sm text-muted-foreground">
                    Waiting...
                  </span>
                </div>
              </div>
            </div>

            <div className="flex justify-end">
              <Button disabled>Generate 3D View</Button>
            </div>
          </div>
        </div>
      </div>
    </main>
  );
}
