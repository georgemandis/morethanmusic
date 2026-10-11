import React, {useEffect, useRef, useState} from 'react';
import useBaseUrl from '@docusaurus/useBaseUrl';
import styles from './LiveSketch.module.css';

// Embeds one of the p5 starters (or ports) in an iframe. allow="midi" is what lets a frame use Web MIDI.
// src is a site-root path like "/starters/p5/pipsqueak/". In production that folder is laid beside the
// build by deploy.sh; in `npm start` it comes from the .repo-links symlinks (see link-repo.mjs).
//
// The box is a fixed 16:9. The sketch keeps its native canvas size (read from the frame once it has
// loaded, same origin) and is scaled down to fit, so an 800x600 starter and a 900x420 port both show whole.
export default function LiveSketch({src, title, width = 800, height = 600}) {
  const url = useBaseUrl(src);
  const boxRef = useRef(null);
  const frameRef = useRef(null);
  const [size, setSize] = useState({w: width, h: height});
  const [scale, setScale] = useState(1);

  useEffect(() => {
    const box = boxRef.current;
    if (!box) return undefined;
    const fit = () => {
      const r = box.getBoundingClientRect();
      if (r.width && r.height) setScale(Math.min(r.width / size.w, r.height / size.h, 1));
    };
    fit();
    const ro = new ResizeObserver(fit);
    ro.observe(box);
    return () => ro.disconnect();
  }, [size]);

  // After the frame loads, read the canvas p5 created and adopt its size. Same origin, so this is allowed.
  const onLoad = () => {
    let tries = 0;
    const look = () => {
      try {
        const c = frameRef.current?.contentDocument?.querySelector('canvas');
        if (c && c.width && c.height) {
          const ratio = window.devicePixelRatio || 1;
          setSize({w: Math.round(c.width / ratio), h: Math.round(c.height / ratio)});
          return;
        }
      } catch (e) {
        return;
      }
      if (tries++ < 20) setTimeout(look, 100);
    };
    look();
  };

  return (
    <div className={styles.box}>
      <p className={styles.note}>
        Click inside the sketch to connect MIDI. No device? The keys named in the code stand in.
      </p>
      <div className={styles.frame} ref={boxRef}>
        <iframe
          ref={frameRef}
          src={url}
          title={title}
          allow="midi *"
          loading="lazy"
          onLoad={onLoad}
          style={{width: size.w, height: size.h, transform: `scale(${scale})`}}
        />
      </div>
      <p className={styles.links}>
        <a href={url} target="_blank" rel="noreferrer">
          Open full page
        </a>
      </p>
    </div>
  );
}
