import { formatDistanceToNow, parseISO } from 'date-fns';
import { ptBR } from 'date-fns/locale';

const relativeTime = {
    mounted() {
      this.updateTime();
      this.timer = setInterval(() => this.updateTime(), 60000); 
    },
    destroyed() {
      clearInterval(this.timer);
    },
    updateTime() {
      const timestamp = this.el.getAttribute("data-timestamp");
      if (timestamp) {
        const date = parseISO(timestamp);
        this.el.innerText = formatDistanceToNow(date, { addSuffix: true, locale: ptBR });
      }
    }
  }

export default relativeTime;